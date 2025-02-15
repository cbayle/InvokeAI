#! /bin/bash
DEBUG=false

startv(){
	ROCMV=$1
	export VIRTUAL_ENV=$(pwd)/venv-rocm$ROCMV
	export INVOKEAI_SRC=$(pwd)/rocm$ROCMV
	# .env set HSA_OVERRIDE_GFX_VERSION HF_HOME
	. ./.env
	echo "===== $VIRTUAL_ENV ====="
	. ./venv-rocm$ROCMV/bin/activate
	env | grep "^VIRTUAL\|^H"
	echo "===== Let's GO ! ====="
	type python
	python -c "from patchmatch import patch_match"
	type invokeai-web
	# https://rocm.docs.amd.com/en/latest/how-to/system-debugging.html
	set -e
	python ./test-torch.py
	if $DEBUG
	then
		export HSAKMT_DEBUG_LEVEL=7
		export HSA_ENABLE_SDMA=0
		export HSA_ENABLE_INTERRUPT=0
		export HSA_SVM_GUARD_PAGES=0
		export HSA_DISABLE_CACHE=1
	fi
	invokeai-web --root ~/invokeai
}

if [ ! -z "$1" ]
then
	startv $1
else
	startv 5.7
fi
