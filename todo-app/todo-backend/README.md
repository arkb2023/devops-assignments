# Express application

Install dependencies with `npm install`

Run with `npm start`

Or in development mode with `npm run dev`

# Visit counter

When running the server, visit http://localhost:3000 to see visit counter, or give environment variable `PORT` to change the port.

# MongoDB

The application has /todos crud which requires a MongoDB. Pass connection url with env `MONGO_URL`

# Redis

Pass connection url with env `REDIS_URL`


todo-backend [main]$ http GET http://localhost:3000/todos
HTTP/1.1 200 OK
Access-Control-Allow-Origin: *
Connection: keep-alive
Content-Length: 2
Content-Type: application/json; charset=utf-8
Date: Tue, 11 Nov 2025 15:46:55 GMT
ETag: W/"2-l9Fw4VUO7kr8CvBlt4zaMCqXZ0w"
Keep-Alive: timeout=5
X-Powered-By: Express

[]


todo-backend [main]$ http POST http://localhost:3000/todos text="Learn containers"
HTTP/1.1 200 OK
Access-Control-Allow-Origin: *
Connection: keep-alive
Content-Length: 81
Content-Type: application/json; charset=utf-8
Date: Tue, 11 Nov 2025 15:47:15 GMT
ETag: W/"51-+Yy0wfQD/bnqMElevOG/tjQZAg4"
Keep-Alive: timeout=5
X-Powered-By: Express

{
    "__v": 0,
    "_id": "69135a83189e29001433af94",
    "done": false,
    "text": "Learn containers"
}


todo-backend [main]$ http GET http://localhost:3000/todos
HTTP/1.1 200 OK
Access-Control-Allow-Origin: *
Connection: keep-alive
Content-Length: 83
Content-Type: application/json; charset=utf-8
Date: Tue, 11 Nov 2025 15:47:36 GMT
ETag: W/"53-Mqtrk4iJmUhUV7Qh/Jc0fuiPZwQ"
Keep-Alive: timeout=5
X-Powered-By: Express

[
    {
        "__v": 0,
        "_id": "69135a83189e29001433af94",
        "done": false,
        "text": "Learn containers"
    }
]


todo-backend [main]$