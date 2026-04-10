set -e

cuda_major=$(echo $cuda_compiler_version | cut -d. -f1)

$PYTHON -m pip install ./nvidia_nvcomp_cu$cuda_major-$PKG_VERSION-*.whl --no-deps

# Query free-threadedness
py_free_threaded=$($PYTHON -c "import sysconfig; print(int(bool(sysconfig.get_config_var('Py_GIL_DISABLED'))))")
PY_VER_t=$(echo $PY_VER | tr -d '.')
[ "$py_free_threaded" -eq 1 ] && PY_VER_t="${PY_VER_t}t"

rm -rvf $SP_DIR/nvidia/nvcomp/include
rm -rvf $SP_DIR/nvidia/nvcomp/libnvcomp.so.*

# Loop through files and delete those whose Python version does not match $PY_VER
for file in $SP_DIR/nvidia/nvcomp/nvcomp_impl.cpython-*-linux-gnu.so; do
    # Extract the Python version from the file name (312 for Python 3.12, 314t for Python 3.14t, etc.)
    file_py_ver=$(echo "$file" | sed -n 's/.*\.cpython-\([0-9][0-9]*t*\)-.*-linux-gnu\.so/\1/p')
    if [[ "$file_py_ver" != "$PY_VER_t" ]]; then
        echo "Deleting $file as its Python version ($file_py_ver) does not match $PY_VER_t"
        rm "$file"
    fi
done

check-glibc $SP_DIR/nvidia/nvcomp/*.so

cp $SP_DIR/nvidia_nvcomp*.dist-info/licenses/LICENSE $SRC_DIR
