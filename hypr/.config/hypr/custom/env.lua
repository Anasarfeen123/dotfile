-- This file will not be overwritten across dots-hyprland updates.
-- The file name is for the sake of organization and does not matter
-- See the corresponding files in ~/.config/hypr/hyprland for examples

-- Aquamarine / DRM fix for hybrid GPUs (NVIDIA + AMD)
-- Fixes eglDupNativeFenceFDANDROID EGL_BAD_PARAMETER crashes
hl.env("AQ_DRM_DEVICES", "/dev/dri/card1:/dev/dri/card2")
hl.env("AQ_MGPU_NO_EXPLICIT", "1")
hl.env("AQ_NO_MODIFIERS", "1")

-- NVIDIA Wayland environment variables
-- Disabled 2026-08-10: forced every GL/VA-API app onto the NVIDIA dGPU by default
-- (panel is driven by the AMD iGPU, card1) — root cause of repeated NVRM OOM errors.
-- Use per-app __NV_PRIME_RENDER_OFFLOAD=1 when an app actually needs the dGPU.
-- hl.env("LIBVA_DRIVER_NAME", "nvidia")
-- Note: GBM_BACKEND=nvidia-drm causes eglDupNativeFenceFDANDROID crashes on hybrid AMD+NVIDIA setups
-- hl.env("GBM_BACKEND", "nvidia-drm")
-- hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
-- hl.env("NVD_BACKEND", "direct")

