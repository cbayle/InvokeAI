#! /bin/bash
#export PYTHON_VERSION=3.11
export UV_COMPILE_BYTECODE=1
#export UV_LINK_MODE=copy
export GPU_DRIVER=rocm

buildvenv(){
	local ROCMV=$1
	if [ ! -d venv-rocm$ROCMV ]
	then
		echo "===== $(type pip) ====="
		echo "===== $(type python 2>/dev/null|| type python3 2>/dev/null) ====="
		uv python install 3.11
		echo "===== Creation VIRTUAL_ENV ====="
		echo "--> VIRTUAL_ENV=$VIRTUAL_ENV"
		echo "--> INVOKEAI_SRC=$INVOKEAI_SRC"
		uv venv --relocatable --prompt invoke$ROCMV --python 3.11 --python-preference only-managed $VIRTUAL_ENV
		. venv-rocm$ROCMV/bin/activate
		echo "===== Creation VIRTUAL_ENV DONE====="
		env | grep VENV
		env | grep UV
		env | grep INVO
		echo "===== Creation VIRTUAL_ENV DONE====="
		echo "===== $(type pip) ====="
		echo "===== $(type python 2>/dev/null|| type python3 2>/dev/null) ====="
		#uv pip install --reinstall pip setuptools wheel
		#deactivate
		. venv-rocm$ROCMV/bin/activate
		echo "===== $(type pip) ====="
		echo "===== $(type python 2>/dev/null|| type python3 2>/dev/null) ====="
	fi
}

buildinvoke(){
	local ROCMV=$1
	if [ ! -d rocm$ROCMV ]
	then
		export VIRTUAL_ENV="$(pwd)/venv-rocm$ROCMV"
		export INVOKEAI_SRC="$(pwd)/rocm$ROCMV"
		export PATH="$VIRTUAL_ENV/bin:$PATH"
		export TORCH_USE_HIP_DSA=True
		echo "===== Build for ROCm $ROCMV ====="
		[ -d rocm$ROCMV ] || mkdir rocm$ROCMV
		rsync -a --delete --exclude invokeai/frontend/web/node_modules \
			--exclude .git/** \
			../invokeai/ rocm$ROCMV/invokeai/
		buildvenv $ROCMV
		#deactivate
		. venv-rocm$ROCMV/bin/activate
		echo "===== INVOKE $(type pip) ====="
		echo "===== INVOKE $(type python) ====="
		if [ -f pyproject.toml-rocm$ROCMV ]
		then
			cp pyproject.toml-rocm$ROCMV rocm$ROCMV/pyproject.toml
		else
			cp ../pyproject.toml rocm$ROCMV/pyproject.toml
		fi
		#uv pip install torch torchvision --reinstall --index-url https://download.pytorch.org/whl/rocm$ROCMV
		#uv pip install torch==2.3.1+rocm5.7 torchvision==0.18.1+rocm5.7 torchaudio==2.3.1+rocm5.7 --extra-index-url https://download.pytorch.org/whl/rocm5.7 -e '..'
		# See matrix at https://pytorch.org/get-started/locally/
		case $ROCMV in 
			5.7)
				extra_index_url="https://download.pytorch.org/whl/rocm$ROCMV"
				;;
			6.3)
				extra_index_url="https://download.pytorch.org/whl/nightly/rocm$ROCMV"
				;;
			6.*)
				extra_index_url="https://download.pytorch.org/whl/rocm$ROCMV"
				;;
		esac
		(cd rocm$ROCMV && uv pip install torch torchvision --extra-index-url $extra_index_url -e ".")
		uv pip list | grep rocm
	else
		echo "===== Build for ROCm $ROCMV Alreadu in rocm$ROCMV ====="
	fi
}

if [ -z "$1" ]
then
	export ROCMV=5.7
else
	export ROCMV=$1
fi

buildinvoke $ROCMV
echo "----- TEST $ROCMV -----"
uv pip list | grep 'rocm\|torch'
