set -e

cuda_major=$(echo $cuda_compiler_version | cut -d. -f1)

$PYTHON -m pip install ./nvidia_nvcomp_cu$cuda_major-$PKG_VERSION-*.whl --no-deps

rm -rvf $SP_DIR/nvidia/nvcomp/include
rm -rvf $SP_DIR/nvidia/nvcomp/libnvcomp.so.*

# Loop through files and delete those whose Python version does not match $PY_VER
for file in $SP_DIR/nvidia/nvcomp/nvcomp_impl.cpython-*-linux-gnu.so; do
    # Extract the Python version from the file name (312 for Python 3.12, etc.)
    file_py_ver=$(echo "$file" | sed -n 's/.*\.cpython-\([0-9][0-9]*\)-.*-linux-gnu\.so/\1/p')
    if [[ "$file_py_ver" != "$(echo $PY_VER | tr -d '.')" ]]; then
        echo "Deleting $file as its Python version ($file_py_ver) does not match $PY_VER"
        rm "$file"
    fi
done

check-glibc $SP_DIR/nvidia/nvcomp/*.so

cp $SP_DIR/nvidia_nvcomp*.dist-info/LICENSE $SRC_DIR
