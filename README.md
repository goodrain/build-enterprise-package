# build-offlice-package

## 运行 Drone Runner

```shell
docker run --detach   \
    --volume=/var/run/docker.sock:/var/run/docker.sock  \
    --env=DRONE_RPC_PROTO=https  \
    --env=DRONE_RPC_HOST=drone.goodrain.com \
    --env=DRONE_RPC_SECRET=60051a710987d909fe6c315ad85a97b1 \
    --env=DRONE_RUNNER_CAPACITY=2  \
    --env=DRONE_RUNNER_NAME=runner-shanghai  \
    --publish=3000:3000  \
    --restart=always  \
    --name=runner \
    -e DRONE_UI_USERNAME=root \
    -e DRONE_UI_PASSWORD=root \
    -e DRONE_RUNNER_LABELS=city:sydney \
    drone/drone-runner-docker:1.8.0
```