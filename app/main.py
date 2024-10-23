from contextlib import asynccontextmanager
from fastapi import FastAPI
from app.database import engine
from app.database import Base
from app.schemas import *
from app import services
from fastapi.middleware.cors import CORSMiddleware
from threading import Thread
import time



class SecondThread:

    def __init__(self):
        self.working = True

    def stop_work(self):
        self.working = False

    def delete_unnecessary_data_from_database(self):
        time_counter = 0
        while self.working is True:

            if time_counter >= 10000:
                time_counter = 0
                services.delete_expired_tokens()
            time_counter += 1

            time.sleep(0.01)

second_thread = SecondThread()
Base.metadata.create_all(bind=engine)

@asynccontextmanager
async def lifespan(app: FastAPI):

    thread = Thread(name='daemon', target=second_thread.delete_unnecessary_data_from_database)
    thread.start()

    yield

    second_thread.stop_work()
    thread.join()


app = FastAPI(lifespan=lifespan)

origins = [
    "*"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.post('/register')
async def register(data: Login):
    return services.register(data)

@app.post('/login')
async def login(data: Login):
    return services.login(data)

@app.post('/refresh-password')
async def refresh_password(data: Email):
    return services.refresh_password(data)

@app.post('/logout')
async def logout(access_token: str, email: str):
    return services.logout(access_token, email)

@app.post('/refresh-token')
async def refresh_token(refresh_token: str, email: str):
    return services.refresh_token(refresh_token, email)

@app.delete('/account')
async def delete_account(access_token: str):
    print("account deleted")

@app.get('/category/all')
async def get_categories(access_token: str):
    # print("all categories")
    return "all categories"

@app.post('/category')
async def add_category(access_token: str, data: CategoryAdd):
    print("category added")

@app.put('/category')
async def edit_category(access_token: str, data: CategoryUpdate):
    print("category edited")

@app.delete('/category')
async def delete_category(access_token: str, data: CategoryName):
    print("category deleted")

@app.get('/category-products')
async def get_category_products(access_token: str, data: CategoryName):
    print("all category_products")

@app.get('/product')
async def get_product(access_token: str, data: ProductName):
    print("product fetched")

@app.post('/product')
async def add_product(access_token: str, data: ProductAdd):
    print("product added")

@app.put('/product')
async def edit_product(access_token: str, data: ProductUpdate):
    print("product edited")

@app.delete('/product')
async def delete_product(access_token: str, data: ProductName):
    print("product deleted")

@app.get('/note/all')
async def get_notes(access_token: str):
    print("all notes")

@app.get('/note')
async def get_note(access_token: str, data: NoteName):
    print("note")

@app.post('/note')
async def add_note(access_token: str, data: NoteAdd):
    print("note added")

@app.put('/note')
async def edit_note(access_token: str, data: NoteUpdate):
    print("note edited")

@app.delete('/note')
async def delete_note(access_token: str, data: NoteName):
    print("note deleted")


# if __name__ == '__main__':
#     uvicorn.run(app, port=8000, host='0.0.0.0')