using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libgdbm"], Symbol("libgdbm")),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/BenLauwens/GDBMBuilder/releases/download/v1.18"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/GDBM.v1.18.0.aarch64-linux-gnu.tar.gz", "6296ac1c91630603cb0ee89657d73947adf359aea25e80ce127eddf274d118b9"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/GDBM.v1.18.0.aarch64-linux-musl.tar.gz", "4db3847215e6a4f6f9b66e4dbd505e85543053d489242d915a3f9fc03a80cb00"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/GDBM.v1.18.0.arm-linux-gnueabihf.tar.gz", "10821eb089c01acfe4570ab5d9b0f551bbc832726582dfcdfbac6ed0bcd00197"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/GDBM.v1.18.0.arm-linux-musleabihf.tar.gz", "acf378d31047b69d784562c3b53ab35bef74aef34c7000bd22846fa5713ed7ed"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/GDBM.v1.18.0.i686-linux-gnu.tar.gz", "0ea1aead5eb714c345b5202387aeb4e0695c3646ebc62914643d5aecd42fec71"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/GDBM.v1.18.0.i686-linux-musl.tar.gz", "5ed7b4a5b0896f2b8b1b1591651069d36c95a76fc0f5c42fa806f02e0451514d"),
    Windows(:i686) => ("$bin_prefix/GDBM.v1.18.0.i686-w64-mingw32.tar.gz", "7a05c97dd7822724167680020e89f051c7c1683c881e4794d98882d6ea789a5f"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/GDBM.v1.18.0.powerpc64le-linux-gnu.tar.gz", "d3cf566636403dc15b05011af8d372d0af066df08d294846ff2c5cd3bfcdd5db"),
    MacOS(:x86_64) => ("$bin_prefix/GDBM.v1.18.0.x86_64-apple-darwin14.tar.gz", "0433454410db18e4336f4a3a8abd2c9cdfc8548c2b95f642333c8444c6000c9a"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/GDBM.v1.18.0.x86_64-linux-gnu.tar.gz", "ed6ca3bd594dd4e66e1e60de057fc17497b0596d3ea2182c1e95e9aacd16449f"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/GDBM.v1.18.0.x86_64-linux-musl.tar.gz", "09432d35b83f472f7cee6166cd21d46c32003411d8277fefebc6547f7ca531de"),
    FreeBSD(:x86_64) => ("$bin_prefix/GDBM.v1.18.0.x86_64-unknown-freebsd11.1.tar.gz", "90f5e25d6604e25145d440552f2ef77219038595efc599f6992459f3b9ecfa6f"),
    Windows(:x86_64) => ("$bin_prefix/GDBM.v1.18.0.x86_64-w64-mingw32.tar.gz", "a72f5f7c0cfa997bed9b5ce2de216751e145790af7cbeb41fea2e4fda5440d10"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
if haskey(download_info, platform_key())
    url, tarball_hash = download_info[platform_key()]
    if unsatisfied || !isinstalled(url, tarball_hash; prefix=prefix)
        # Download and install binaries
        install(url, tarball_hash; prefix=prefix, force=true, verbose=verbose)
    end
elseif unsatisfied
    # If we don't have a BinaryProvider-compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform $(triplet(platform_key())) is not supported by this package!")
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)
