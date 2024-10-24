from pydantic import BaseModel
import datetime


class Email(BaseModel):
    email: str

    class Config:
        from_attributes = True


class Login(Email):
    password: str


    class Config:
        from_attributes = True


class CategoryName(BaseModel):
    name: str


    class Config:
        from_attributes = True


class CategoryAdd(CategoryName):
    photo: str | None = None


    class Config:
        from_attributes = True


class CategoryUpdate(BaseModel):
    old_name: str
    name: str 
    photo: str | None = None


    class Config:
        from_attributes = True


class ProductName(BaseModel):
    name: str 
    category_name: str


    class Config:
        from_attributes = True
    

class ProductAdd(ProductName):
    quantity: str
    photo: str | None = None
    audio: str | None = None
    video: str | None = None


    class Config:
        from_attributes = True


class ProductUpdate(ProductName):
    old_name: str
    quantity: str | None = None
    photo: str | None = None 
    audio: str | None = None
    video: str | None = None


    class Config:
        from_attributes = True


class NoteName(BaseModel):
    name: str


    class Config:
        from_attributes = True


class NoteAdd(NoteName):
    text: str


    class Config:
        from_attributes = True


class NoteUpdate(BaseModel):
    old_name: str
    name: str | None = None
    text: str


    class Config:
        from_attributes = True












