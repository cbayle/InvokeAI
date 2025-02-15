#! /bin/bash
build(){
	ROCMV=$1
	if [ -d rocm$ROCMV/invokeai/frontend/web/ ]
	then
		export VIRTUAL_ENV="$(pwd)/venv-rocm$ROCMV"
		echo "--> VIRTUAL_ENV=$VIRTUAL_ENV"
		export INVOKEAI_SRC="$(pwd)/rocm$ROCMV"
		echo "--> INVOKEAI_SRC=$INVOKEAI_SRC"
		export PATH="$VIRTUAL_ENV/bin:$PATH"
		#PNPM_HOME="$(pwd)/pnpm" ;
		#PATH="$PNPM_HOME:$PATH" ;
		(cd rocm$ROCMV/invokeai/frontend/web/ ;
		corepack use pnpm@8.x ;
		#corepack enable ;
		corepack pnpm install --frozen-lockfile ;
		corepack npx vite build
		)
	fi
}

if [ -z "$1" ]
then
	build 5.7
else
	build $1
fi
