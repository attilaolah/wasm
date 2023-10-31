Module["onRuntimeInitialized"] = function(): void {
  this["av_version_info"] = cwrap("av_version_info", "string", []);
  this["avutil_configuration"] = cwrap("avutil_configuration", "string", []);
  this["avutil_license"] = cwrap("avutil_license", "string", []);
  this["av_pix_fmt_desc_next"] = cwrap("av_pix_fmt_desc_next", "number", ["number"]);
};
