docker compose -f docker-compose.dev.yaml build  
docker compose -f docker-compose.dev.yaml up -d  
docker compose -f docker-compose.dev.yaml ps -a  
http GET http://localhost:8080  
http GET http://localhost:8080/api/todos  
http POST http://localhost:8080/api/todos text="message1"  
http GET http://localhost:8080/api/todos  
docker compose -f docker-compose.dev.yaml down --volumes  --remove-orphans  

