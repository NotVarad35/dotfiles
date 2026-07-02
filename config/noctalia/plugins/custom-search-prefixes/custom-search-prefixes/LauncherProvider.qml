import QtQuick
import qs.Commons

Item {
    id: root

    property var pluginApi: null
    property var launcher: null
    property string name: "Custom Search Prefixes"

    property bool handleSearch: true
    property string supportedLayouts: "list"

    readonly property var cfg: pluginApi?.pluginSettings || ({})
    readonly property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

    function getPrefixes() {
        return cfg.prefixes ?? defaults.prefixes ?? [];
    }

    function getEnabledPrefixes() {
        return getPrefixes().filter(function(p) { return p.enabled !== false; });
    }

    function findPrefix(query) {
        var prefixes = getEnabledPrefixes();
        for (var i = 0; i < prefixes.length; i++) {
            var p = prefixes[i];
            if (query.startsWith(">" + p.prefix)) {
                var after = query.slice(p.prefix.length + 1).trim();
                var exact = query === ">" + p.prefix || query === ">" + p.prefix + " ";
                return { prefix: p, rawQuery: after, emptyQuery: exact };
            }
        }
        return null;
    }

    function getResults(searchText) {
        var rawText = searchText.trim();
        var match = findPrefix(rawText);

        if (!match) return [];
        if (match.emptyQuery) {
            return [{
                "name": pluginApi?.tr("launcher.noQuery"),
                "description": pluginApi?.tr("launcher.search", { query: "...", site: match.prefix.name }),
                "icon": match.prefix.icon,
                "isTablerIcon": true
            }];
        }

        var query = match.rawQuery;
        if (!query) return [];

        var url = match.prefix.url + encodeURIComponent(query);
        return [{
            "name": pluginApi?.tr("launcher.search", { query: query, site: match.prefix.name }),
            "description": pluginApi?.tr("launcher.command.description_singular", { site: match.prefix.name }),
            "icon": match.prefix.icon,
            "isTablerIcon": true,
            "_score": 1000,
            "onActivate": function() {
                Qt.openUrlExternally(url);
                if (launcher) launcher.close();
            }
        }];
    }

    function handleCommand(searchText) {
        return findPrefix(searchText.trim()) !== null;
    }

    function commands() {
        var prefixes = getEnabledPrefixes();
        var cmds = [];
        for (var i = 0; i < prefixes.length; i++) {
            var p = prefixes[i];
            var prefix = p.prefix;
            cmds.push({
                "name": ">" + prefix,
                "description": pluginApi?.tr("launcher.command.description_singular", { site: p.name }),
                "icon": p.icon,
                "isTablerIcon": true,
                "onActivate": (function(cmd) {
                    return function() {
                        launcher.setSearchText(">" + cmd + " ");
                    };
                })(prefix)
            });
        }
        return cmds;
    }
}
