from pydantic import BaseModel


class Login(BaseModel):
    email: str
    password: str


    class Config:
        from_attributes = True