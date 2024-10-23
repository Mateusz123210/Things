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
def register(data: Login):

    if validating.validate_email(data.email) is False:
        raise HTTPException(status_code=400, detail="Email has invalid format")
    
    db_user = crud.get_user_by_email(email=data.email)
    if db_user:
        raise HTTPException(status_code=409, detail="This email currently exists in app!")
        
    if validating.validate_password(data.password) is False:
        raise HTTPException(status_code=400, detail="Password has invalid format")
    
    hashed_password = hashing.hash_password(data.password)

    utc=pytz.UTC

    db_user = crud.create_user(email=data.email, password=hashed_password, 
                               last_login_attempt=datetime.datetime.now(datetime.UTC))
                                  
    return {}

@transactional
def login(data: Login):
    
    if validating.validate_email(data.email) is False:
        raise HTTPException(status_code=400, detail="Email has invalid format")
    
    if validating.validate_password(data.password) is False:
        raise HTTPException(status_code=400, detail="Password has invalid format")
    
    db_user = crud.get_user_by_email(email=data.email)

    if db_user is None:
        raise HTTPException(status_code=409, detail="Invalid email or password!")
        
    hashed_password = hashing.hash_password(data.password)

    utc=pytz.UTC
    
    access_token_key = jwt_token_generator.generate_jwt_secret_key()

    while check_access_token_key(db_user, access_token_key) is False:
        access_token_key = jwt_token_generator.generate_jwt_secret_key()

    refresh_token_key = jwt_token_generator.generate_jwt_secret_key()

    while check_refresh_token_key(db_user, refresh_token_key) is False:
        refresh_token_key = jwt_token_generator.generate_jwt_secret_key()

    access_token = create_access_token(data.email, access_token_key)
    refresh_token = create_refresh_token(data.email, refresh_token_key)

    access_token_expiration_time = datetime.datetime.now(datetime.UTC) + datetime.timedelta(minutes=15)
    refresh_token_expiration_time = datetime.datetime.now(datetime.UTC) + datetime.timedelta(minutes=60*24)

    crud.login_user(db_user, access_token_key, access_token_expiration_time, refresh_token_key, 
                    refresh_token_expiration_time)
                                  
    return {"access_token": access_token, "refresh_token": refresh_token}

@transactional
def refresh_password(data: Email):
    raise HTTPException(status_code=501, detail="Not implemented yet!")

@transactional
def logout(access_token: str, email: str):
    db_user = crud.get_user_by_email(email=email)
    if db_user is None:
        raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Could not validate credentials",
                headers={"WWW-Authenticate": "Bearer"},
            )
    db_user_tokens = crud.get_user_tokens(db_user)

    found = False
    expired = True
    found_token = None

    for db_token in db_user_tokens:
        try:
            payload = jwt.decode(
                access_token, db_token.access_token, algorithms=[ALGORITHM]
            )
            if payload["sub"] == email:
                found = True
                utc=pytz.UTC
                datetime_now = datetime.datetime.now(datetime.UTC)
                token_expiration_time = utc.localize(db_token.access_token_expiration_time)
                if datetime_now <= token_expiration_time:
                    expired = False    
                    found_token = db_token            
    
        except(jwt.JWTError, ValidationError):
            pass
        
    if found is False:
        raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Could not validate credentials",
                headers={"WWW-Authenticate": "Bearer"},
            )
    if expired is True:
        raise HTTPException(
                status_code = status.HTTP_401_UNAUTHORIZED,
                detail="Token expired",
                headers={"WWW-Authenticate": "Bearer"},
            )
    crud.delete_token(found_token)
    return {}

@transactional
def refresh_token(refresh_token, email):
    db_user = crud.get_user_by_email(email=email)
    if db_user is None:
        raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Could not validate credentials",
                headers={"WWW-Authenticate": "Bearer"},
            )
    db_user_tokens = crud.get_user_tokens(db_user)

    found_token = None
    found = False
    expired = True

    for db_token in db_user_tokens:

        try:
            payload = jwt.decode(
                refresh_token, db_token.refresh_token, algorithms=[ALGORITHM]
            )
            if payload["sub"] == email:
                found = True
                utc=pytz.UTC
                datetime_now = datetime.datetime.now(datetime.UTC)
                token_expiration_time = utc.localize(db_token.refresh_token_expiration_time)
                if datetime_now <= token_expiration_time:
                    expired = False       
                    found_token = db_token         
    
        except(jwt.JWTError, ValidationError):
            pass
        
    if found is False:
        raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Could not validate credentials",
                headers={"WWW-Authenticate": "Bearer"},
            )
    if expired is True:

        raise HTTPException(
                status_code = status.HTTP_401_UNAUTHORIZED,
                detail="Token expired",
                headers={"WWW-Authenticate": "Bearer"},
            )

    access_token_key = jwt_token_generator.generate_jwt_secret_key()

    while check_access_token_key(db_user, access_token_key) is False:
        access_token_key = jwt_token_generator.generate_jwt_secret_key()

    refresh_token_key = jwt_token_generator.generate_jwt_secret_key()

    while check_refresh_token_key(db_user, refresh_token_key) is False:
        refresh_token_key = jwt_token_generator.generate_jwt_secret_key()

    access_token = create_access_token(email, access_token_key)
    refresh_token = create_refresh_token(email, refresh_token_key)

    access_token_expiration_time = datetime.datetime.now(datetime.UTC) + datetime.timedelta(minutes=15)
    refresh_token_expiration_time = datetime.datetime.now(datetime.UTC) + datetime.timedelta(minutes=60*24)

    crud.update_token(found_token, access_token_key, access_token_expiration_time, refresh_token_key,
                      refresh_token_expiration_time)

    return {"access_token": access_token, "refresh_token": refresh_token}

# with open("./keys/second_server_url.env") as file:
#     second_server_url = file.read()

# key = b'ftN9pKojZezJO0q_fBOlqAT5Iwh5Y_Ybref_KvOdlMY='
# f = Fernet(key)

# with open("./keys/secret_key.env", "rb") as encrypted_file:
#     encrypted = encrypted_file.read()

# token = f.decrypt(encrypted).decode("utf-8")

# queue_sender = QueueSender()




# def confirm_registration1(data: BasicConfirmationWithVerificationCode):
#     result = confirm_registration(data)
#     if "exception" in result.keys():
#         raise HTTPException(status_code=400, detail=result["exception"])
#     else:
#         return result

# @transactional
# def confirm_registration(data: BasicConfirmationWithVerificationCode):
#     user = crud.get_user_by_email(email=data.email)
#     if user is None:
#         raise HTTPException(status_code=400, detail="User does not exist!")
#     if user.is_active is True:
#         raise HTTPException(status_code=400, detail="User is active!")
#     utc=pytz.UTC
#     verification_timeout = utc.localize(user.registration_confirmation_code_expiration_time)
#     datetime_now = datetime.now(UTC)
#     if datetime_now > verification_timeout:
#         crud.delete_user(user) 
#         return {"exception": "Verification code expired"}
#     if user.registration_confirmation_code_enter_attempts >= 2:
#         if user.registration_confirmation_code != data.verification_code:
#             crud.delete_user(user) 
#             return {"exception": "Too many atempts. Account deleted"}
#     if user.registration_confirmation_code != data.verification_code:
#         crud.add_verification_code_attempt(user) 
#         return {"exception": "Invalid verification code"}
#     crud.activate_user(user)
#     crud.delete_user_tokens(user)
#     queue_sender.send_to_queue(data.email)

#     return {"message": "User activated"}

# @transactional
# def refresh_token(data):
#     db_user = crud.get_user_by_email(email=data.email)
#     if db_user is None:
#         raise HTTPException(status_code=400, detail="User does not exist!")
#     if db_user.is_active is False:
#         raise HTTPException(status_code=400, detail="User is not active!")
#     db_user_tokens = crud.get_user_tokens(db_user)
#     found_token = None

#     found = False
#     expired = True

#     for db_token in db_user_tokens:
#         if db_token.refresh_token is None:
#             continue
#         try:
#             payload = jwt.decode(
#                 data.refresh_token, db_token.refresh_token, algorithms=[ALGORITHM]
#             )
#             if payload["sub"] == data.email:
#                 found = True
#                 utc=pytz.UTC
#                 datetime_now = datetime.now(UTC)
#                 token_expiration_time = utc.localize(db_token.refresh_token_expiration_time)
#                 if datetime_now <= token_expiration_time:
#                     expired = False       
#                     found_token = db_token         
    
#         except(jwt.JWTError, ValidationError):
#             pass
        
#     if found is False:
#         raise HTTPException(
#                 status_code=status.HTTP_403_FORBIDDEN,
#                 detail="Could not validate credentials",
#                 headers={"WWW-Authenticate": "Bearer"},
#             )
#     if expired is True:
#         raise HTTPException(
#                 status_code = status.HTTP_401_UNAUTHORIZED,
#                 detail="Token expired",
#                 headers={"WWW-Authenticate": "Bearer"},
#             )
#     if found_token.logged is False:
#         raise HTTPException(status_code=400, detail="User not logged!")

#     access_token_key = jwt_token_generator.generate_jwt_secret_key()
#     while check_access_token_key(db_user, access_token_key) is False:
#         access_token_key = jwt_token_generator.generate_jwt_secret_key()
#     refresh_token_key = jwt_token_generator.generate_jwt_secret_key()
#     while check_refresh_token_key(db_user, refresh_token_key) is False:
#         refresh_token_key = jwt_token_generator.generate_jwt_secret_key()
#     access_token = create_access_token(data.email, access_token_key)
#     refresh_token = create_refresh_token(data.email, refresh_token_key)
#     access_token_expiration_time = datetime.now(UTC) + timedelta(minutes=15)
#     refresh_token_expiration_time = datetime.now(UTC) + timedelta(minutes=60*24)

#     new_token = TokenSchema(access_token=access_token_key,
#             access_token_expiration_time= access_token_expiration_time,
#             refresh_token=refresh_token_key,
#             refresh_token_expiration_time=refresh_token_expiration_time)
#     crud.update_token(found_token, new_token)

#     return {"message": "Token updated",
#             "access_token": access_token,
#             "refresh_token": refresh_token}













    # email = data.username    
    # db_user = crud.get_user_by_email(email=email)
    # if db_user is None:
    #     raise HTTPException(status_code=400, detail="Invalid username or password")
    # if db_user.is_active is False:
    #     raise HTTPException(status_code=400, detail="User is not active!")
    # hashed_password = main.objects[1].hash_password(data.password)
    # if hashed_password != db_user.password:
    #     raise HTTPException(status_code=400, detail="Invalid username or password")

    # verification_code = verification_code_generator.generate_verification_code()
    # verification_code_expiration_time = datetime.now(UTC) + timedelta(minutes=15)
    # access_token_key = jwt_token_generator.generate_jwt_secret_key()
    # while check_access_token_key(db_user, access_token_key) is False:
    #     access_token_key = jwt_token_generator.generate_jwt_secret_key()
    # access_token_expiration_time = datetime.now(UTC) + timedelta(minutes=15)
    # access_token = create_access_token(email, access_token_key)

    # crud.create_user_tokens2(db_user=db_user.id, access_token=access_token_key, refresh_token=None, 
    #                         access_token_expiration_time=access_token_expiration_time,
    #                         refresh_token_expiration_time=None,verification_code=verification_code,
    #                         verification_code_expiration_time=verification_code_expiration_time,
    #                         verification_code_type="login")

    # try:
    #     mail_sender.send_email_with_verification_code_for_login(main.objects[0], email, verification_code)
    # except Exception:
    #     raise HTTPException(
    #             status_code=500,
    #             detail="Internal Server Error",
    #         ) 
    # return {"message": "Confirm login",
    #         "access_token": access_token}

# def confirm_login1(data: BasicConfirmationWithVerificationCode):
#     result = confirm_login(data)
#     if "exception" in result.keys():
#         raise HTTPException(status_code=400, detail=result["exception"])
#     else:
#         return result

# @transactional
# def confirm_login(data: BasicConfirmationWithVerificationCode):
#     user = crud.get_user_by_email(email=data.email)
#     if user is None:
#         raise HTTPException(status_code=400, detail="User does not exist!")
#     if user.is_active is False:
#         raise HTTPException(status_code=400, detail="User is not active!")

#     db_user_tokens = crud.get_user_tokens(user)
#     found_token = None

#     found = False
#     expired = True

#     for db_token in db_user_tokens:
#         try:
#             payload = jwt.decode(
#                 data.access_token, db_token.access_token, algorithms=[ALGORITHM]
#             )
#             if payload["sub"] == data.email:
#                 found = True
#                 utc=pytz.UTC
#                 datetime_now = datetime.now(UTC)
#                 token_expiration_time = utc.localize(db_token.access_token_expiration_time)
#                 if datetime_now <= token_expiration_time:
#                     expired = False       
#                     found_token = db_token         
    
#         except(jwt.JWTError, ValidationError):
#             pass
        
#     if found is False:
#         raise HTTPException(
#                 status_code=status.HTTP_403_FORBIDDEN,
#                 detail="Could not validate credentials",
#                 headers={"WWW-Authenticate": "Bearer"},
#             )
#     if expired is True:
#         raise HTTPException(
#                 status_code = status.HTTP_401_UNAUTHORIZED,
#                 detail="Token expired",
#                 headers={"WWW-Authenticate": "Bearer"},
#             )
#     if found_token.logged is True:
#         raise HTTPException(status_code=400, detail="You are currently logged!")
#     if found_token.verification_code_type is not None and found_token.verification_code_type != "login":
#         raise HTTPException(status_code=400, detail="Operation not permitted!")
#     utc=pytz.UTC
#     token_timeout = utc.localize(found_token.verification_code_expiration_time)
#     datetime_now = datetime.now(UTC)
#     if datetime_now > token_timeout:
#         crud.delete_token(found_token) 
#         return {"exception": "Verification code expired. Log in again"}
#     if found_token.verification_code_enter_attempts >= 2:
#         if found_token.verification_code != data.verification_code:
#             crud.delete_token(found_token) 
#             return {"exception": "Too many atempts. Log in again"}
#     if found_token.verification_code != None and found_token.verification_code != data.verification_code:
#         crud.add_verification_code_attempt2(found_token) 
#         return {"exception": "Invalid verification code"}
    
#     access_token_key = jwt_token_generator.generate_jwt_secret_key()
#     while check_access_token_key(user, access_token_key) is False:
#         access_token_key = jwt_token_generator.generate_jwt_secret_key()
#     refresh_token_key = jwt_token_generator.generate_jwt_secret_key()
#     while check_refresh_token_key(user, refresh_token_key) is False:
#         refresh_token_key = jwt_token_generator.generate_jwt_secret_key()
#     access_token = create_access_token(data.email, access_token_key)
#     refresh_token = create_refresh_token(data.email, refresh_token_key)
#     access_token_expiration_time = datetime.now(UTC) + timedelta(minutes=15)
#     refresh_token_expiration_time = datetime.now(UTC) + timedelta(minutes=60*24)
    
#     crud.update_token_after_login(found_token=found_token, access_token=access_token_key, 
#                                 access_token_expiration_time=access_token_expiration_time,
#                                 refresh_token=refresh_token_key, refresh_token_expiration_time= refresh_token_expiration_time)

#     return {"message": "User logged in",
#             "access_token": access_token,
#             "refresh_token": refresh_token}

# @transactional
# def delete_account(data: BasicConfirmationForDeleteAccount):
#     email = data.email    
#     db_user = crud.get_user_by_email(email=email)
#     if db_user is None:
#         raise HTTPException(status_code=400, detail="Invalid username or password")
#     if db_user.is_active is False:
#         raise HTTPException(status_code=400, detail="User is not active!")
#     hashed_password = main.objects[1].hash_password(data.password)
#     if hashed_password != db_user.password:
#         raise HTTPException(status_code=400, detail="Invalid username or password")
#     crud.delete_user_with_keys(db_user)

#     send_data= {"user": data.email, "token": token}
#     try:
#         httpx.post(url=second_server_url + "delete-messages", json = send_data, verify="./keys/cert.cer")
#     except Exception:
#         raise HTTPException(
#                 status_code=500,
#                 detail="Internal Server Error",
#             )
#     return {"message": "Account deleted"}

# @transactional
# def logout(data: BasicConfirmation):
#     db_user = crud.get_user_by_email(email=data.email)
#     db_user_tokens = crud.get_user_tokens(db_user)

#     found = False
#     expired = True
#     found_token = None

#     for db_token in db_user_tokens:
#         try:
#             payload = jwt.decode(
#                 data.access_token, db_token.access_token, algorithms=[ALGORITHM]
#             )
#             if payload["sub"] == data.email:
#                 found = True
#                 utc=pytz.UTC
#                 datetime_now = datetime.now(UTC)
#                 token_expiration_time = utc.localize(db_token.access_token_expiration_time)
#                 if datetime_now <= token_expiration_time:
#                     expired = False    
#                     found_token = db_token            
    
#         except(jwt.JWTError, ValidationError):
#             pass
        
#     if found is False:
#         raise HTTPException(
#                 status_code=status.HTTP_403_FORBIDDEN,
#                 detail="Could not validate credentials",
#                 headers={"WWW-Authenticate": "Bearer"},
#             )
#     if expired is True:
#         raise HTTPException(
#                 status_code = status.HTTP_401_UNAUTHORIZED,
#                 detail="Token expired",
#                 headers={"WWW-Authenticate": "Bearer"},
#             )
#     crud.delete_token(found_token)
#     return {"message": "User logged out"}

# def check_access_token_key(user, access_token_key):
#     db_user_tokens = crud.get_user_tokens(user)
#     for db_token in db_user_tokens:
#         if db_token.access_token == access_token_key:
#             return False
#     return True

# def check_refresh_token_key(user, refresh_token_key):
#     db_user_tokens = crud.get_user_tokens(user)
#     for db_token in db_user_tokens:
#         if db_token.refresh_token == refresh_token_key:
#             return False
#     return True

# @transactional
# def validate_user_token(data):

#     db_user = crud.get_user_by_email(email=data.email)
#     if db_user is None:
#         raise HTTPException(
#                 status_code=status.HTTP_403_FORBIDDEN,
#                 detail="User does not exist",
#                 headers={"WWW-Authenticate": "Bearer"},
#             )
#     db_user_tokens = crud.get_user_tokens(db_user)

#     found = False
#     expired = True

#     for db_token in db_user_tokens:
#         try:
#             payload = jwt.decode(
#                 data.access_token, db_token.access_token, algorithms=[ALGORITHM]
#             )
#             if payload["sub"] == data.email:
#                 found = True
#                 utc=pytz.UTC
#                 datetime_now = datetime.now(UTC)
#                 token_expiration_time = utc.localize(db_token.access_token_expiration_time)
#                 if datetime_now <= token_expiration_time:
#                     expired = False                
    
#         except(jwt.JWTError, ValidationError):
#             pass
        
#     if found is False:
#         raise HTTPException(
#                 status_code=status.HTTP_403_FORBIDDEN,
#                 detail="Could not validate credentials",
#                 headers={"WWW-Authenticate": "Bearer"},
#             )
#     if expired is True:
#         raise HTTPException(
#                 status_code = status.HTTP_401_UNAUTHORIZED,
#                 detail="Token expired",
#                 headers={"WWW-Authenticate": "Bearer"},
#             )
#     return data

# @transactional
# def validate_user_token_with_verification_if_user_logged(data):

#     db_user = crud.get_user_by_email(email=data.email)
#     if db_user is None:
#         raise HTTPException(
#                 status_code=status.HTTP_403_FORBIDDEN,
#                 detail="User does not exist",
#                 headers={"WWW-Authenticate": "Bearer"},
#             )
#     if db_user.is_active is False:
#         raise HTTPException(
#                 status_code=status.HTTP_403_FORBIDDEN,
#                 detail="User is not active",
#                 headers={"WWW-Authenticate": "Bearer"},
#             )
#     db_user_tokens = crud.get_user_tokens(db_user)

#     found_token = None
#     found = False
#     expired = True

#     for db_token in db_user_tokens:
#         try:
#             payload = jwt.decode(
#                 data.access_token, db_token.access_token, algorithms=[ALGORITHM]
#             )
#             if payload["sub"] == data.email:
#                 found = True
#                 utc=pytz.UTC
#                 datetime_now = datetime.now(UTC)
#                 token_expiration_time = utc.localize(db_token.access_token_expiration_time)
#                 if datetime_now <= token_expiration_time:
#                     expired = False    
#                     found_token = db_token            
    
#         except(jwt.JWTError, ValidationError):
#             pass
        
#     if found is False:
#         raise HTTPException(
#                 status_code=status.HTTP_403_FORBIDDEN,
#                 detail="Could not validate credentials",
#                 headers={"WWW-Authenticate": "Bearer"},
#             )
#     if expired is True:
#         raise HTTPException(
#                 status_code = status.HTTP_401_UNAUTHORIZED,
#                 detail="Token expired",
#                 headers={"WWW-Authenticate": "Bearer"},
#             )
#     if found_token.logged is False:
#         raise HTTPException(
#                 status_code=status.HTTP_403_FORBIDDEN,
#                 detail="You are not logged",
#                 headers={"WWW-Authenticate": "Bearer"},
#             )
#     return data

# @transactional
# def send_message(data: BasicConfirmationForMessageSend):
#     receiver = crud.get_user_by_email(data.receiver)
#     if receiver is None:
#         raise HTTPException(
#                 status_code=status.HTTP_400_BAD_REQUEST,
#                 detail="There is no register user with this email (bad receiver)!",
#             )
#     if receiver.is_active is False:
#         raise HTTPException(
#                 status_code=status.HTTP_400_BAD_REQUEST,
#                 detail="There is no register user with this email (bad receiver)!",
#             )

#     send_data= {"first_user": data.email, "second_user": data.receiver, "message": data.message,
#              "token": token}

#     try:
#         response = httpx.post(url=second_server_url + "send-message", json = send_data, verify="./keys/cert.cer")
#     except Exception:
#         raise HTTPException(
#                 status_code=500,
#                 detail="Internal Server Error",
#             )
    
#     if response.status_code != 200:
#         json_answer = None
#         try:
#             json_answer = (response.json())["detail"]
#         except Exception as e:
#             json_answer = response.json()
            
#         raise HTTPException(
#                 status_code=response.status_code,
#                 detail=json_answer,
#             )
    
#     elif response.status_code >= 500:
#         raise HTTPException(
#                 status_code=500,
#                 detail="Internal Server Error",
#             )
    
#     else:
#         return JSONResponse(status_code=response.status_code, content=response.json())

# @transactional
# def get_messages(data: BasicConfirmationForMessageFetch):
#     receiver = crud.get_user_by_email(data.caller)
#     if receiver is None:
#         raise HTTPException(
#                 status_code=status.HTTP_400_BAD_REQUEST,
#                 detail="There is no register user with this email (bad receiver)!",
#             )
#     if receiver.is_active is False:
#         raise HTTPException(
#                 status_code=status.HTTP_400_BAD_REQUEST,
#                 detail="There is no register user with this email (bad receiver)!",
#             )

#     send_data= {"first_user": data.email, "second_user": data.caller, "token": token}

#     try:
#         response = httpx.post(url=second_server_url + "get-messages", json = send_data, verify="./keys/cert.cer")
#     except Exception:
#         raise HTTPException(
#                 status_code=500,
#                 detail="Internal Server Error",
#             )
#     if response.status_code != 200 and response.status_code != 204:
#         json_answer = None
#         try:
#             json_answer = (response.json())["detail"]
#         except Exception as e:
#             json_answer = response.json()
            
#         raise HTTPException(
#                 status_code=response.status_code,
#                 detail=json_answer,
#             )
    
#     elif response.status_code >= 500:
#         raise HTTPException(
#                 status_code=500,
#                 detail="Internal Server Error",
#             )
    
#     else:
#         if response.status_code == 200:
#             return JSONResponse(status_code=response.status_code, content=response.json())
#         else:
#             return Response(status_code=204)

# @transactional
# def get_aes_key(data):
#     receiver = crud.get_user_by_email(data.receiver)
#     if data.receiver == data.email:
#         raise HTTPException(
#                 status_code=status.HTTP_400_BAD_REQUEST,
#                 detail="Sender cannot be the same, as receiver!",
#             )

#     if receiver is None:
#         raise HTTPException(
#                 status_code=status.HTTP_400_BAD_REQUEST,
#                 detail="There is no register user with this email (bad receiver)!",
#             )
#     if receiver.is_active is False:
#         raise HTTPException(
#                 status_code=status.HTTP_400_BAD_REQUEST,
#                 detail="There is no register user with this email (bad receiver)!",
#             )
#     user = crud.get_user_by_email(data.email)
#     if user is None:
#         raise HTTPException(
#                 status_code=status.HTTP_400_BAD_REQUEST,
#                 detail="There is no register user with this email!",
#             )
    
#     found_aes_key = crud.get_key(user, receiver)
#     if found_aes_key:
#         return {"key": found_aes_key.aes_key,
#                 "initialization_vector": found_aes_key.initialization_vector}
#     else:
#         found_aes_key = crud.get_key(receiver, user)
#         if found_aes_key:
#             return {"key": found_aes_key.aes_key,
#                 "initialization_vector": found_aes_key.initialization_vector}
#         else:
#             key = aes_generator.get_random_key()
#             initialization_vector = aes_generator.get_random_initialization_vector()
#             crud.add_key(user, receiver, key, initialization_vector)
#             return {"key": key, "initialization_vector": initialization_vector}
        
# @transactional
# def get_available_callers(data):
#     db_user = crud.get_user_by_email(email=data.email)
#     if db_user is None:
#         raise HTTPException(
#                 status_code=status.HTTP_400_BAD_REQUEST,
#                 detail="User does not exist")
#     fetched1 = crud.get_available_callers1(db_user.id)
#     fetched2 = crud.get_available_callers2(db_user.id)
#     callers1 = [crud.get_user(x.second_user_id).email for x in fetched1]
#     callers2 = [crud.get_user(x.first_user_id).email for x in fetched2]
#     callers = callers1 + callers2

#     return {"message": "callers fetched", "callers": callers}

@transactional
def delete_expired_tokens():

    tokens = crud.get_all_tokens()
    for token in tokens:

        utc=pytz.UTC
        datetime_now = datetime.datetime.now(datetime.UTC)
        token_expiration_time = utc.localize(token.refresh_token_expiration_time)

        if datetime_now > token_expiration_time:
            crud.delete_token(token)

def check_access_token_key(user, access_token_key):
    db_user_tokens = crud.get_user_tokens(user)
    for db_token in db_user_tokens:
        if db_token.access_token == access_token_key:
            return False
    return True

def check_refresh_token_key(user, refresh_token_key):
    db_user_tokens = crud.get_user_tokens(user)
    for db_token in db_user_tokens:
        if db_token.refresh_token == refresh_token_key:
            return False
    return True