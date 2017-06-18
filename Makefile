CONTEXT = tchughesiv
VERSION = v0.1
IMAGE_NAME = starter-dumb-init
REGISTRY = docker-registry.default.svc.cluster.local

# Allow user to pass in OS build options
ifeq ($(TARGET),rhel7)
	DFILE := Dockerfile.${TARGET}
else
	TARGET := centos7
	DFILE := Dockerfile
endif

all: build
build:
	docker build --pull -t ${CONTEXT}/${IMAGE_NAME}:${TARGET}-${VERSION} -t ${CONTEXT}/${IMAGE_NAME} -f ${DFILE} .
	@if docker images ${CONTEXT}/${IMAGE_NAME}:${TARGET}-${VERSION}; then touch build; fi

lint:
	dockerfile_lint -f Dockerfile
	dockerfile_lint -f Dockerfile.rhel7

test:
	$(eval CONTAINERID=$(shell docker run -tdi -u $(shell shuf -i 1000010000-1000020000 -n 1) ${CONTEXT}/${IMAGE_NAME}:${TARGET}-${VERSION}))
	@sleep 5
	@docker exec ${CONTAINERID} ps aux
	@docker rm -f ${CONTAINERID}

openshift-test:
	$(eval PROJ_RANDOM=$(shell shuf -i 100000-999999 -n 1))
	oc new-project test-${PROJ_RANDOM}
	docker login -u `oc whoami` -p `oc whoami -t` ${REGISTRY}:5000
	docker tag ${CONTEXT}/${IMAGE_NAME}:${TARGET}-${VERSION} ${REGISTRY}:5000/test-${PROJ_RANDOM}/${IMAGE_NAME}
	docker push ${REGISTRY}:5000/test-${PROJ_RANDOM}/${IMAGE_NAME}
	oc new-app ${IMAGE_NAME}
	oc rollout status -w dc/${IMAGE_NAME}
	oc status
	sleep 5
	oc describe pod `oc get pod --template '{{(index .items 0).metadata.name }}'`
	oc exec `oc get pod --template '{{(index .items 0).metadata.name }}'` ps aux

run:
	docker run -tdi -u `shuf -i 1000010000-1000020000 -n 1` ${CONTEXT}/${IMAGE_NAME}:${TARGET}-${VERSION}

clean:
	rm -f build