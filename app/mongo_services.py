from app.mongo_database import collection_things
from fastapi import HTTPException
from app.decorators.mongo_database import mongo_transactional
from app.decorators.database import transactional
from app import deps
from app.schemas import *

@mongo_transactional
@transactional
def get_user_categories(access_token, email, session):
    deps.validate_user_token(access_token, email)

    user = collection_things.find_one({"email": email}, session=session)

    if user:
        
        user_categories = user["categories"]

        return user_categories
    
    else:
        return {}

@mongo_transactional
@transactional
def add_category(access_token, email, data: CategoryAdd, session):

    deps.validate_user_token(access_token, email)

    if len(data.name) == 0:
        raise HTTPException(status_code=400, detail="Category field is empty!")

    user = collection_things.find_one({"email": email}, session=session)

    if user:
        
        user_categories = user["categories"]

        for i in range (len(user_categories)):
            if data.name == user_categories[i][0]:
                raise HTTPException(status_code=400, detail="You already have category with this name!")
        
        user_categories.append([data.name, data.photo])

        filter = { '_id': user["_id"] }
        new_values = { "$set": { 'categories': user_categories } }

        collection_things.update_one(filter, new_values, session=session)
    
    else:

        insert_data = {"email": email, "categories": [[data.name, data.photo]], "products": [], "notes": []}
        collection_things.insert_one(insert_data)

    return {}

@mongo_transactional
@transactional
def edit_category(access_token, email, data, session):

    deps.validate_user_token(access_token, email)
    
    if len(data.old_name) == 0:
        raise HTTPException(status_code=400, detail="Old category name is invalid!")
    
    if len(data.name) == 0:
        raise HTTPException(status_code=400, detail="Category field is empty!")

    user = collection_things.find_one({"email": email}, session=session)

    if user:
        
        user_categories = user["categories"]

        category_index = None

        for i in range (len(user_categories)):
            if data.old_name == user_categories[i][0]:
                category_index = i
                
        if category_index is None:
            raise HTTPException(status_code=400, detail="Category does not exist!")
        
        if data.old_name == data.name:
            if user_categories[category_index][1] != data.photo:
                user_categories[category_index][1] = data.photo

                user_products = user["products"]
                for i in range (len(user_products)):
                    if data.old_name == user_products[i][1]:
                        user_products[i][1] = data.name
                
                filter = { '_id': user["_id"] }
                new_values = { "$set": { 'products': user_products } }
                
                collection_things.update_one(filter, new_values, session=session)

                new_values = { "$set": { 'categories': user_categories } }
                
                collection_things.update_one(filter, new_values, session=session)
            
            else:
                raise HTTPException(status_code=400, detail="You have not changed anything!")
        else:

            for i in range (len(user_categories)):
                if data.name == user_categories[i][0]:
                    raise HTTPException(status_code=400, detail="New category name already exists!")
            
            user_categories[category_index] = [data.name, data.photo]

            user_products = user["products"]
            for i in range (len(user_products)):
                if data.old_name == user_products[i][1]:
                    user_products[i][1] = data.name
            
            filter = { '_id': user["_id"] }
            
            new_values = { "$set": { 'products': user_products } }
                
            collection_things.update_one(filter, new_values, session=session)
            
            new_values = { "$set": { 'categories': user_categories } }

            collection_things.update_one(filter, new_values, session=session)
    
    else:

        raise HTTPException(status_code=400, detail="Category does not exist!")

    return {}

@mongo_transactional
@transactional
def delete_category(access_token, email, data, session):

    deps.validate_user_token(access_token, email)
    
    if len(data.name) == 0:
        raise HTTPException(status_code=400, detail="Category name not given!")
    
    user = collection_things.find_one({"email": email}, session=session)

    if user:

        user_categories = user["categories"]

        category_index = None

        for i in range (len(user_categories)):
            if data.name == user_categories[i][0]:
                category_index = i
                
        if category_index is None:
            raise HTTPException(status_code=400, detail="Category does not exist!")
        
        del user_categories[category_index]

        filter = { '_id': user["_id"] }
        new_values = { "$set": { 'categories': user_categories } }

        collection_things.update_one(filter, new_values, session=session)

        user_products = user["products"]
        for i in reversed (range (len (user_products))):
            if data.name == user_products[i][1]:
                del user_products[i]
    
        filter = { '_id': user["_id"] }
            
        new_values = { "$set": { 'products': user_products } }
            
        collection_things.update_one(filter, new_values, session=session)

    else:
        raise HTTPException(status_code=400, detail="Category does not exist!")
    
    return {}

@mongo_transactional
@transactional
def get_category_products(access_token, email, name, session):

    deps.validate_user_token(access_token, email)
    
    if len(name) == 0:
        raise HTTPException(status_code=400, detail="Category name not given!")

    user = collection_things.find_one({"email": email}, session=session)

    if user:
        
        user_categories = user["categories"]

        category_index = None

        for i in range (len(user_categories)):
            if name == user_categories[i][0]:
                category_index = i
                
        if category_index is None:
            raise HTTPException(status_code=400, detail="Category does not exist!")
        
        user_products = user["products"]

        for i in reversed (range (len (user_products))):
            if name != user_products[i][1]:
                del user_products[i]
        
        return user_products
        
    else:

        raise HTTPException(status_code=400, detail="Category does not exist!")

@mongo_transactional
@transactional
def get_product(access_token, email, name, category_name, session):

    deps.validate_user_token(access_token, email)

    if len(name) == 0:
            raise HTTPException(status_code=400, detail="Product name not given!")
    
    if len(category_name) == 0:
            raise HTTPException(status_code=400, detail="Category name not given!")
    
    user = collection_things.find_one({"email": email}, session=session)

    if user:
        
        user_categories = user["categories"]

        category_index = None

        for i in range (len(user_categories)):
            if category_name == user_categories[i][0]:
                category_index = i
                
        if category_index is None:
            raise HTTPException(status_code=400, detail="Category does not exist!")
        
        user_products = user["products"]

        for i in range (len (user_products)):
            if name == user_products[i][0] and category_name == user_products[i][1]:
                return user_products[i]
               
    else:

        raise HTTPException(status_code=400, detail="Product does not exist!")
    
    return {}
    
@mongo_transactional
@transactional
def add_product(access_token, email, data, session):
    deps.validate_user_token(access_token, email)

    if len(data.name) == 0:
        raise HTTPException(status_code=400, detail="Product name not given!")
    
    if len(data.category_name) == 0:
        raise HTTPException(status_code=400, detail="Category name not given!")
    
    if len(data.quantity) == 0:
        raise HTTPException(status_code=400, detail="Product quantity not given!")

    user = collection_things.find_one({"email": email}, session=session)

    if user:
        
        user_categories = user["categories"]

        category_index = None

        for i in range (len(user_categories)):
            if data.category_name == user_categories[i][0]:
                category_index = i
                
        if category_index is None:

            raise HTTPException(status_code=400, detail="Category does not exist!")
        
        user_products = user["products"]
        for i in range (len (user_products)):
            if data.name == user_products[i][0] and data.category_name == user_products[i][1]:
                raise HTTPException(status_code=400, detail="Product with this name already exists!")

        user_products.append([data.name, data.category_name, data.quantity, data.photo, data.audio, data.video])

        filter = { '_id': user["_id"] }
            
        new_values = { "$set": { 'products': user_products } }
            
        collection_things.update_one(filter, new_values, session=session)

    else: 

        raise HTTPException(status_code=400, detail="Category does not exist!")
    
    return {}

@mongo_transactional
@transactional
def edit_product(access_token, email, data, session):

    deps.validate_user_token(access_token, email)

    if len(data.old_name) == 0:
        raise HTTPException(status_code=400, detail="Old product name not given!")
    
    if len(data.category_name) == 0:
        raise HTTPException(status_code=400, detail="Category name not given!")
    
    if len(data.name) == 0:
        raise HTTPException(status_code=400, detail="Product name not given!")

    user = collection_things.find_one({"email": email}, session=session)

    if user:
        product_index = None

        user_products = user["products"]

        for i in range (len (user_products)):
            if data.old_name == user_products[i][0] and data.category_name == user_products[i][1]:

                product_index = i

        if product_index is None:

                raise HTTPException(status_code=400, detail="Product with this name does not exist!")

        for i in range (len (user_products)):
            if data.name == user_products[i][0] and data.category_name == user_products[i][1]:

                raise HTTPException(status_code=400, detail="New product name already exists!")

        user_products[product_index] = [data.name, data.category_name, data.quantity, data.photo, data.audio, data.video]

        filter = { '_id': user["_id"] }
            
        new_values = { "$set": { 'products': user_products } }
            
        collection_things.update_one(filter, new_values, session=session)

    else: 

        raise HTTPException(status_code=400, detail="Category does not exist!")
    
    return {}

@mongo_transactional
@transactional
def delete_product(access_token, email, data, session):

    deps.validate_user_token(access_token, email)
    
    if len(data.name) == 0:
        raise HTTPException(status_code=400, detail="Product name not given!")

    user = collection_things.find_one({"email": email}, session=session)

    if user:
        product_index = None

        user_products = user["products"]

        for i in range (len (user_products)):
            if data.name == user_products[i][0] and data.category_name == user_products[i][1]:

                product_index = i

        if product_index is None:

                raise HTTPException(status_code=400, detail="Product with this name does not exist!")

        del user_products[product_index]

        filter = { '_id': user["_id"] }
            
        new_values = { "$set": { 'products': user_products } }
            
        collection_things.update_one(filter, new_values, session=session)

    else: 

        raise HTTPException(status_code=400, detail="Category does not exist!")
    
    return {}

@mongo_transactional
@transactional
def get_notes(access_token, email, session):

    deps.validate_user_token(access_token, email)

    user = collection_things.find_one({"email": email}, session=session)

    if user:

        user_notes = user["notes"]

        for i in range(len(user_notes)):

            note_length = len(user_notes[i][1])

            if note_length > 10:

                user_notes[i][1] = user_notes[i][1] [:7] + "..."

        return user_notes

    return {}

@mongo_transactional
@transactional
def get_note(access_token, email, name, session):

    deps.validate_user_token(access_token, email)

    if len(name) == 0:
        raise HTTPException(status_code=400, detail="Note tittle not given!")

    user = collection_things.find_one({"email": email}, session=session)

    if user:

        user_notes = user["notes"]

        for i in range (len (user_notes)):
            if name == user_notes[i][0]:
                return user_notes[i]
                
    raise HTTPException(status_code=400, detail="Note does not exist!")
    
@mongo_transactional
@transactional
def add_note(access_token, email, data, session):

    deps.validate_user_token(access_token, email)
    
    if len(data.name) == 0:
        raise HTTPException(status_code=400, detail="Note title not given!")

    user = collection_things.find_one({"email": email}, session=session)

    if user:
        
        user_notes = user["notes"]

        for i in range (len(user_notes)):
            if data.name == user_notes[i][0]:
                raise HTTPException(status_code=400, detail="You already have note with this title!")
        
        user_notes.append([data.name, data.text])

        filter = { '_id': user["_id"] }
        new_values = { "$set": { 'notes': user_notes } }

        collection_things.update_one(filter, new_values, session=session)
    
    else:

        insert_data = {"email": email, "categories": [], "products": [], "notes": [[data.name, data.text]]}
        collection_things.insert_one(insert_data)

    return {}

@mongo_transactional
@transactional
def edit_note(access_token, email, data, session):

    deps.validate_user_token(access_token, email)
    
    if len(data.old_name) == 0:
        raise HTTPException(status_code=400, detail="Old note name not given!")
    
    if len(data.name) == 0:
        raise HTTPException(status_code=400, detail="Note name not given!")

    user = collection_things.find_one({"email": email}, session=session)

    if user:
        
        user_notes = user["notes"]

        note_index = None

        for i in range (len(user_notes)):
            if data.old_name == user_notes[i][0]:
                note_index = i
                
        if note_index is None:
            raise HTTPException(status_code=400, detail="Note does not exist!")
        
        if data.old_name == data.name:
            if user_notes[note_index][1] != data.text:
                user_notes[note_index][1] = data.text

                filter = { '_id': user["_id"] }

                new_values = { "$set": { 'notes': user_notes } }
                
                collection_things.update_one(filter, new_values, session=session)
            
            else:
                raise HTTPException(status_code=400, detail="You have not changed anything!")
        else:

            for i in range (len(user_notes)):
                if data.name == user_notes[i][0]:
                    raise HTTPException(status_code=400, detail="New note title already exists!")
            
            user_notes[note_index] = [data.name, data.text]
            
            filter = { '_id': user["_id"] }
            
            new_values = { "$set": { 'notes': user_notes } }

            collection_things.update_one(filter, new_values, session=session)
    
    else:

        raise HTTPException(status_code=400, detail="Category does not exist!")

    return {}

@mongo_transactional
@transactional
def delete_note(access_token, email, data, session):

    deps.validate_user_token(access_token, email)
    
    if len(data.name) == 0:
        raise HTTPException(status_code=400, detail="Note title not given!")

    user = collection_things.find_one({"email": email}, session=session)

    if user:

        user_notes = user["notes"]

        for i in range (len (user_notes)):
            if data.name == user_notes[i][0]:

                del user_notes[i]

                filter = { '_id': user["_id"] }
            
                new_values = { "$set": { 'notes': user_notes } }
                    
                collection_things.update_one(filter, new_values, session=session)

                return {}
        
        raise HTTPException(status_code=400, detail="Note does not exist!")

    else: 

        raise HTTPException(status_code=400, detail="Note does not exist!")
    
@mongo_transactional
@transactional
def delete_user(email: str, session):
    
    collection_things.find_one_and_delete({"email": email}, session=session)
