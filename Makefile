CONTEXT = tchughesiv
VERSION = v0.1
IMAGE_NAME = starter-dumb-init

# Allow user to pass in OS build options
ifeq ($(TARGET),rhel7)
	OS := rhel7
	DFILE := Dockerfile
else
	OS := centos7
	DFILE := Dockerfile.${OS}
endif

all: build
build:
	docker build --pull -t ${CONTEXT}/${IMAGE_NAME}:${OS}-${VERSION} -t ${CONTEXT}/${IMAGE_NAME} -f ${DFILE} .
	@if docker images ${CONTEXT}/${IMAGE_NAME}:${OS}-${VERSION}; then touch build; fi

clean:
	rm -f build