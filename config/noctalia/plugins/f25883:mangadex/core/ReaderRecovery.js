var TRANSITION_NOISE_REASONS = {
    panel_open: true,
    panel_reopen: true,
    reader_width_changed: true,
    reader_height_changed: true
};

function nextRenderEpoch(currentEpoch) {
    var numeric = Number(currentEpoch || 0);
    if (isNaN(numeric) || numeric < 0) {
        numeric = 0;
    }
    return Math.round(numeric) + 1;
}

function normalizeRecoveryReason(reason) {
    var normalized = String(reason || "").toLowerCase().trim();
    return normalized === "" ? "layout_change" : normalized;
}

function isTransitionNoiseReason(reason) {
    var normalized = normalizeRecoveryReason(reason);
    return !!TRANSITION_NOISE_REASONS[normalized];
}

function shouldRemountForReason(reason) {
    var normalized = normalizeRecoveryReason(reason);
    if (normalized === "layout_change") {
        return false;
    }

    if (normalized === "layout_settled") {
        return true;
    }

    return normalized === "panel_open"
        || normalized === "panel_reopen"
        || normalized === "page_model_changed"
        || normalized === "chapter_changed"
        || normalized === "reader_width_changed"
        || normalized === "reader_height_changed"
        || normalized === "manual_refetch"
        || normalized === "blank_view_recovery";
}

function isCriticalRemountReason(reason) {
    var normalized = normalizeRecoveryReason(reason);
    if (!shouldRemountForReason(normalized)) {
        return false;
    }

    if (normalized === "layout_settled") {
        return false;
    }

    return !isTransitionNoiseReason(normalized);
}

function shouldResetSourceForReason(reason) {
    var normalized = normalizeRecoveryReason(reason);
    if (!shouldRemountForReason(normalized)) {
        return false;
    }

    return normalized === "page_model_changed"
        || normalized === "chapter_changed"
        || normalized === "manual_refetch"
        || normalized === "blank_view_recovery";
}
