module CVImgCodecs

export imread, imwrite

using LibOpenCV
using CVCore
using Cxx

libopencv_imgcodecs = LibOpenCV.find_library_e("libopencv_imgcodecs")
try
    Libdl.dlopen(libopencv_imgcodecs, Libdl.RTLD_GLOBAL)
catch e
    warn("You might need to set DYLD_LIBRARY_PATH to load dependencies proeprty.")
    rethrow(e)
end

cxx"""
#include <opencv2/imgcodecs.hpp>
"""

for name in [
    # Imread flags
    :IMREAD_UNCHANGED,
    :IMREAD_GRAYSCALE,
    :IMREAD_COLOR,
    :IMREAD_ANYCOLOR,
    :IMREAD_LOAD_GDAL,
    :IMREAD_REDUCED_GRAYSCALE_2,
    :IMREAD_REDUCED_COLOR_2,
    :IMREAD_REDUCED_GRAYSCALE_4,
    :IMREAD_REDUCED_COLOR_4,
    :IMREAD_REDUCED_GRAYSCALE_8,
    :IMREAD_REDUCED_COLOR_8,

    # Imwrite flags
    :IMWRITE_JPEG_QUALITY,
    :IMWRITE_JPEG_PROGRESSIVE,
    :IMWRITE_JPEG_OPTIMIZE,
    :IMWRITE_JPEG_RST_INTERVAL,
    :IMWRITE_JPEG_LUMA_QUALITY,
    :IMWRITE_JPEG_CHROMA_QUALITY,
    :IMWRITE_PNG_COMPRESSION,
    :IMWRITE_PNG_STRATEGY,
    :IMWRITE_PNG_BILEVEL,
    :IMWRITE_PXM_BINARY,
    :IMWRITE_WEBP_QUALITY,

    # ImwritePNGFlags
    :IMWRITE_PNG_STRATEGY_DEFAULT,
    :IMWRITE_PNG_STRATEGY_FILTERED,
    :IMWRITE_PNG_STRATEGY_HUFFMAN_ONLY,
    :IMWRITE_PNG_STRATEGY_RLE,
    :IMWRITE_PNG_STRATEGY_FIXED,
    ]
    ex = Expr(:macrocall, Symbol("@icxx_str"), string("cv::", name, ";"))
    @eval global const $name = $ex
end

function imread(name::AbstractString, flag=IMREAD_UNCHANGED)
    Mat(@cxx cv::imread(pointer(name), flag))
end

imwrite(filename::AbstractString, img::AbstractCvMat) =
    icxx"cv::imwrite($(pointer(filename)), $(img.handle));"
imwrite(filename::AbstractString, img::AbstractCvMat, params) =
    icxx"cv::imwrite($(pointer(filename)), $(img.handle), $params);"

end # module
