"""Workspace rule for downloading subpackage dependencies."""

load("//lib/aec:package.bzl", "download_aec")
load("//lib/bz2:package.bzl", "download_bz2")
load("//lib/cblas:package.bzl", "download_cblas")
load("//lib/ceres:package.bzl", "download_ceres")
load("//lib/curl:package.bzl", "download_curl")
load("//lib/deflate:package.bzl", "download_deflate")
load("//lib/eigen:package.bzl", "download_eigen")
load("//lib/exiv2:package.bzl", "download_exiv2")
load("//lib/expat:package.bzl", "download_expat")
load("//lib/ffi:package.bzl", "download_ffi")
load("//lib/fftw:package.bzl", "download_fftw")
load("//lib/flex:package.bzl", "download_flex")
load("//lib/gcc:package.bzl", "download_gcc")
load("//lib/gdal:package.bzl", "download_gdal")
load("//lib/geos:package.bzl", "download_geos")
load("//lib/geotiff:package.bzl", "download_geotiff")
load("//lib/gflags:package.bzl", "download_gflags")
load("//lib/gif:package.bzl", "download_gif")
load("//lib/glog:package.bzl", "download_glog")
load("//lib/gmp:package.bzl", "download_gmp")
load("//lib/grass:package.bzl", "download_grass")
load("//lib/hdf:package.bzl", "download_hdf")
load("//lib/hdf5:package.bzl", "download_hdf5")
load("//lib/iconv:package.bzl", "download_iconv")
load("//lib/jpegturbo:package.bzl", "download_jpegturbo")
load("//lib/jq:package.bzl", "download_jq")
load("//lib/lcms:package.bzl", "download_lcms")
load("//lib/lz4:package.bzl", "download_lz4")
load("//lib/lzma:package.bzl", "download_lzma")
load("//lib/lzo:package.bzl", "download_lzo")
load("//lib/m4:package.bzl", "download_m4")
load("//lib/mpdecimal:package.bzl", "download_mpdecimal")
load("//lib/mpfr:package.bzl", "download_mpfr")
load("//lib/musl:package.bzl", "download_musl")
load("//lib/ncurses:package.bzl", "download_ncurses")
load("//lib/oniguruma:package.bzl", "download_oniguruma")
load("//lib/openjpeg:package.bzl", "download_openjpeg")
load("//lib/openssl:package.bzl", "download_openssl")
load("//lib/pano13:package.bzl", "download_pano13")
load("//lib/png:package.bzl", "download_png")
load("//lib/proj:package.bzl", "download_proj")
load("//lib/python:package.bzl", "download_python")
load("//lib/readline:package.bzl", "download_readline")
load("//lib/sqlite:package.bzl", "download_sqlite")
load("//lib/suitesparse:package.bzl", "download_suitesparse")
load("//lib/szip:package.bzl", "download_szip")
load("//lib/tcl:package.bzl", "download_tcl")
load("//lib/tiff:package.bzl", "download_tiff")
load("//lib/tirpc:package.bzl", "download_tirpc")
load("//lib/vigra:package.bzl", "download_vigra")
load("//lib/webp:package.bzl", "download_webp")
load("//lib/xml:package.bzl", "download_xml")
load("//lib/xslt:package.bzl", "download_xslt")
load("//lib/z:package.bzl", "download_z")
load("//lib/zstd:package.bzl", "download_zstd")

def download_lib():
    """Download all library sources."""
    download_aec()
    download_bz2()
    download_cblas()
    download_ceres()
    download_curl()
    download_deflate()
    download_eigen()
    download_exiv2()
    download_expat()
    download_ffi()
    download_fftw()
    download_flex()
    download_gcc()
    download_gdal()
    download_geos()
    download_geotiff()
    download_gflags()
    download_gif()
    download_glog()
    download_gmp()
    download_grass()
    download_hdf()
    download_hdf5()
    download_iconv()
    download_jpegturbo()
    download_jq()
    download_lcms()
    download_lz4()
    download_lzma()
    download_lzo()
    download_m4()
    download_mpdecimal()
    download_mpfr()
    download_musl()
    download_ncurses()
    download_oniguruma()
    download_openjpeg()
    download_openssl()
    download_pano13()
    download_png()
    download_proj()
    download_python()
    download_readline()
    download_sqlite()
    download_suitesparse()
    download_szip()
    download_tcl()
    download_tiff()
    download_tirpc()
    download_vigra()
    download_webp()
    download_xml()
    download_xslt()
    download_z()
    download_zstd()
