import uvicorn
from fastapi import FastAPI
from schemas import Login

app = FastAPI()


@app.post('/login')
async def login(data: Login):
    print("logged")





if __name__ == '__main__':
    uvicorn.run(app, port=8000, host='0.0.0.0')