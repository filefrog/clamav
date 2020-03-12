IMAGE ?= filefrog/clamav
TAG   ?= latest

build:
	docker build . -t $(IMAGE):$(TAG)

push: build
	docker push $(IMAGE):$(TAG)
