from fastapi import HTTPException, status  #, Depends, Response, status
# from fastapi.responses import JSONResponse
# from fastapi.security import OAuth2PasswordRequestForm
from app import crud
from app.generators import jwt_token_generator
from app.utils import create_access_token, create_refresh_token
import datetime
from app.schemas import *
from app import validating
from app.decorators.database import transactional
import pytz
from jose import jwt

from app.utils import (
    ALGORITHM
)
from pydantic import ValidationError
import httpx
from cryptography.fernet import Fernet

from app import hashing, tokens_generator

@transactional
def validate_user_token(access_token, email):

    db_user = crud.get_user_by_email(email=email)
    # if db_user is None:
    #     raise HTTPException(
    #             status_code=status.HTTP_403_FORBIDDEN,
    #             detail="Could not validate credentials",
    #             headers={"WWW-Authenticate": "Bearer"},
    #         )
    # db_user_tokens = crud.get_user_tokens(db_user)

    # found = False
    # expired = True

    # for db_token in db_user_tokens:
    #     try:
    #         payload = jwt.decode(
    #             access_token, db_token.access_token, algorithms=[ALGORITHM]
    #         )
    #         if payload["sub"] == email:
    #             found = True
    #             utc=pytz.UTC
    #             datetime_now = datetime.datetime.now(datetime.UTC)
    #             token_expiration_time = utc.localize(db_token.access_token_expiration_time)
    #             if datetime_now <= token_expiration_time:
    #                 expired = False                
    
    #     except(jwt.JWTError, ValidationError):
    #         pass
        
    # if found is False:
    #     raise HTTPException(
    #             status_code=status.HTTP_403_FORBIDDEN,
    #             detail="Could not validate credentials",
    #             headers={"WWW-Authenticate": "Bearer"},
    #         )
    # if expired is True:
    #     raise HTTPException(
    #             status_code = status.HTTP_401_UNAUTHORIZED,
    #             detail="Token expired",
    #             headers={"WWW-Authenticate": "Bearer"},
    #         )
    return db_user