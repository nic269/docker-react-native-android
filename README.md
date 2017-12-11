# docker-react-native-android
Dockerhub

# run docker
build docker image

```sh
docker build -t react-native-android:1.0 .
```

To enter the development environment

```sh
docker-compose run development
```

Inside container

```sh
/#> cd app
/app#> adb reverse tcp:8081 tcp:8081 # you'll need android > 5.1 for this
/app#> react-native start
/app#> react-native run-android
```

To open access container

```sh
docker exec -it reactnativeandroid_development_run_1 /bin/bash
```
or
```sh
docker exec -it <container_id> /bin/bash
```

To shut down the development container

```sh
docker-compose down -v
```