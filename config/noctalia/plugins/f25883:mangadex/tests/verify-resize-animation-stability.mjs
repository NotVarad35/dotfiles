#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import vm from "node:vm";
import assert from "node:assert/strict";

const repoRoot = path.resolve(path.dirname(new URL(import.meta.url).pathname), "../..");

function readWorkspaceFile(relativePath) {
  return fs.readFileSync(path.join(repoRoot, relativePath), "utf8");
}

function loadScript(relativePath, extras = {}) {
  const code = readWorkspaceFile(relativePath);
  const context = {
    console,
    Date,
    Math,
    JSON,
    String,
    Number,
    Boolean,
    Object,
    Array,
    RegExp,
    Error,
    parseInt,
    parseFloat,
    isNaN,
    ...extras,
  };

  vm.createContext(context);
  vm.runInContext(code, context, { filename: relativePath });
  return context;
}

function testReaderRecoveryHelpers() {
  const recovery = loadScript("mangadex/core/ReaderRecovery.js");

  assert.equal(recovery.isTransitionNoiseReason("panel_open"), true, "panel_open should be treated as transition-noise reason");
  assert.equal(recovery.isTransitionNoiseReason("reader_width_changed"), true, "width change should be treated as transition-noise reason");
  assert.equal(recovery.shouldRemountForReason("layout_settled"), true, "layout_settled should trigger a single remount after transition settle");
  assert.equal(recovery.isCriticalRemountReason("chapter_changed"), true, "chapter_changed should stay critical");
  assert.equal(recovery.shouldResetSourceForReason("layout_settled"), false, "layout_settled remount should not force source reset");
  assert.equal(recovery.shouldResetSourceForReason("page_model_changed"), true, "page model changes should still reset source");
}

function testMainPanelContracts() {
  const mainQml = readWorkspaceFile("mangadex/Main.qml");
  const panelQml = readWorkspaceFile("mangadex/Panel.qml");
  const settingsQml = readWorkspaceFile("mangadex/Settings.qml");
  const manifestJson = JSON.parse(readWorkspaceFile("mangadex/manifest.json"));

  assert.equal(mainQml.includes("property int readerTransitionSettleMs"), true, "Main.qml should expose transition settle duration");
  assert.equal(mainQml.includes("property int readerTransitionStuckThresholdMs"), true, "Main.qml should expose transition stuck-loading threshold");
  assert.equal(mainQml.includes("property int readerTransitionSettleEpoch"), true, "Main.qml should expose transition settle epoch signal");
  assert.equal(mainQml.includes("function beginReaderTransition("), true, "Main.qml should start transition sessions");
  assert.equal(mainQml.includes("function settleReaderTransition("), true, "Main.qml should settle transition sessions");
  assert.equal(mainQml.includes("reader.render_epoch.suppressed"), true, "Main.qml should log suppressed remounts");
  assert.equal(mainQml.includes("reader.render_epoch.critical_bypass"), true, "Main.qml should log critical bypass diagnostics");
  assert.equal(mainQml.includes("function requestTransitionSettledPageRecovery("), true, "Main.qml should expose post-settle page recovery helper");
  assert.equal(mainQml.includes("chapter.open.reuse_loaded"), true, "Main.qml should reuse already loaded chapter state on reopen");
  assert.equal(mainQml.includes("allowChapterFallback !== false"), true, "Main.qml should support explicit chapter-fallback control for targeted recovery");
  assert.equal(mainQml.includes("reason || \"manual_refetch\","), true, "Main.qml should route manual refetch through targeted recovery");
  assert.equal(mainQml.includes("targetSlotKey,\n      false"), true, "Manual targeted refetch should disable automatic chapter fallback");
  assert.equal(mainQml.includes('"targeted-recovery-failed"'), true, "Main.qml should keep targeted recovery failures in page-level error state");

  assert.equal(panelQml.includes('import "core/ReaderRecovery.js" as ReaderRecovery'), true, "Panel.qml should import recovery helper module");
  assert.equal(panelQml.includes("function onReaderTransitionSettleEpochChanged()"), true, "Panel.qml should react to transition settle events");
  assert.equal(panelQml.includes("function recoverVisibleLoadingPages("), true, "Panel.qml should perform post-settle visible page reconciliation");
  assert.equal(panelQml.includes("mainInstance.requestTransitionSettledPageRecovery"), true, "Panel.qml should request targeted transition recovery via Main API");
  assert.equal(panelQml.includes("ReaderRecovery.shouldResetSourceForReason"), true, "Panel.qml should avoid source resets for layout-only remount reasons");

  assert.equal(settingsQml.includes("valueTransitionSettleMs"), true, "Settings.qml should expose transition settle setting");
  assert.equal(settingsQml.includes("valueTransitionStuckThresholdMs"), true, "Settings.qml should expose transition stuck threshold setting");

  assert.equal(typeof manifestJson.metadata.defaultSettings.reader.transitionSettleMs, "number", "Manifest should define transition settle default");
  assert.equal(typeof manifestJson.metadata.defaultSettings.reader.transitionStuckThresholdMs, "number", "Manifest should define transition stuck-threshold default");
}

function main() {
  testReaderRecoveryHelpers();
  testMainPanelContracts();
  console.log("Verification passed: transition-settle remount suppression and visible-page recovery contracts are present.");
}

main();
