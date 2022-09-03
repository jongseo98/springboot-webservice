# !/bin/bash

REPOSITORY=/home/ec2-user/app/step2
PROJECT_NAME=springboot-webservice

echo "> Build 파일 복사"

cp $REPOSITORY/zip/*.jar $REPOSITORY/

echo "> 현재 구동중인 애플리케이션 pid 확인"

CURRENT_PID=$(pgrep -fl springboot-webservice | grep jar | awk '{print $1}')

# 현재 수행 중인 스프링 부트 애플리케이션의 PID를 찾는다. 실행 중이면 종료
echo "현재 구동중인 애플리케이션 : $CURRENT_PID"

if [ -z "$CURRNET_PID" ]; then
  echo "> kill -15 $CURRENT_PID"
  kill -15 $CURRENT_PID
  sleep 5
fi

echo "> 새 애플리케이션 배포"

JAR_NAME=$(ls -tr $REPOSITORY/*.jar | tail -n 1)

echo "> JAR Name : $JAR_NAME"

echo "> $JAR_NAME 에 실행권한 추가"

chmod +x $JAR_NAME # jar 파일에 nohup으로 실행할 수 있게 실행권한을 추가한다.
echo "> $JAR_NAME 실행"

nohup java -jar \
  -Dspring.config.location=classpath:/application.properties,classpath:/application-real.properties,/home/ec2-user/app/application-oauth.properties,/home/ec2-user/app/application-real-db.properties \
  -Dspring.profiles.active=real \
  $JAR_NAME > $REPOSITORY/nohup.out 2>&1 &
  # nohup 실행시 CodeDeploy가 무한대기하는 이슈를 해결하기 위해 사용