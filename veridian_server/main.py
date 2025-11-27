import os
import uuid
from datetime import datetime, timedelta
from typing import List, Optional
from fastapi import FastAPI, Depends, HTTPException, status, Body
from fastapi.security import OAuth2PasswordBearer
from fastapi.middleware.cors import CORSMiddleware
from motor.motor_asyncio import AsyncIOMotorClient
from passlib.context import CryptContext
from pydantic import BaseModel, EmailStr
from jose import JWTError, jwt
from openai import AsyncOpenAI

from dotenv import load_dotenv

load_dotenv()


OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

SECRET_KEY = "a7b02fedbd3c6f1e797f70b501310a9638c40a1bab32e4dcd57f5be66e784ae9"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 10080  # 7 дней
MONGO_URL = "mongodb://localhost:27017"

if not OPENAI_API_KEY:
    print("WARNING: OPENAI_API_KEY not found! Chat support will not work.")
    openai_client = None
else:
    print("OpenAI API Key loaded successfully.")
    openai_client = AsyncOpenAI(api_key=OPENAI_API_KEY)

app = FastAPI(title="Veridian Banking API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

client = AsyncIOMotorClient(MONGO_URL)
db = client.veridian_db

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")


class UserResponse(BaseModel):
    id: str
    firstName: str
    surname: str
    patronymic: Optional[str] = None
    iin: str
    email: str
    phone: str
    avatarUrl: Optional[str] = None
    createdAt: str
    updatedAt: str

    @property
    def name(self) -> str:
        return f"{self.firstName} {self.surname}"


class UserCreate(BaseModel):
    firstName: str
    surname: str
    patronymic: Optional[str] = None
    iin: str
    email: EmailStr
    password: str
    phone: str


class Token(BaseModel):
    token: str
    user: UserResponse


class BankAccount(BaseModel):
    id: str
    userId: str
    accountNumber: str
    accountName: str
    accountType: str
    balance: float
    currency: str
    isActive: bool
    createdAt: str
    updatedAt: str


class Card(BaseModel):
    id: str
    userId: str
    accountId: str
    cardNumber: str
    cardHolderName: str
    expiryDate: str
    cvv: str
    cardType: str
    status: str
    cardColor: Optional[str] = "0xFF1E1E1E"
    createdAt: str
    updatedAt: str


class Transaction(BaseModel):
    id: str
    userId: str
    accountId: str
    type: str
    category: str
    amount: float
    currency: str
    recipient: Optional[str] = None
    description: Optional[str] = None
    status: str
    transactionDate: str
    createdAt: str
    updatedAt: str


class TransferRequest(BaseModel):
    accountId: str
    cardNumber: str
    amount: float
    description: Optional[str] = None


class TransferByPhoneRequest(BaseModel):
    accountId: str
    phoneNumber: str
    amount: float
    description: Optional[str] = None


class UserSearchRequest(BaseModel):
    phone: str


class SupportChatRequest(BaseModel):
    message: str
    language: Optional[str] = 'ru'


class Bill(BaseModel):
    id: str
    userId: str
    payeeName: str
    category: str
    amount: float
    currency: str
    dueDate: str
    isPaid: bool
    createdAt: str
    updatedAt: str


class Loan(BaseModel):
    id: str
    userId: str
    provider: str
    amount: float
    remainingAmount: float
    currency: str
    interestRate: float
    nextPaymentDate: str
    status: str
    createdAt: str
    updatedAt: str


class TransferRecipient(BaseModel):
    id: str
    userId: str
    name: str
    accountNumber: str
    bankName: str
    recipientType: str
    isFavorite: bool
    createdAt: str
    updatedAt: str


BCRYPT_MAX_LENGTH = 72


def get_password_hash(password):
    truncated_password = password[:BCRYPT_MAX_LENGTH]
    return pwd_context.hash(truncated_password)


def verify_password(plain_password, hashed_password):
    truncated_password = plain_password[:BCRYPT_MAX_LENGTH]
    return pwd_context.verify(truncated_password, hashed_password)


def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


async def get_current_user(token: str = Depends(oauth2_scheme)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    user = await db.users.find_one({"email": email})
    if user is None:
        raise credentials_exception
    return UserResponse(**user)


def now_iso():
    return datetime.now().isoformat()


def generate_id():
    return str(uuid.uuid4())


async def seed_user_data(user_id: str, user_name: str):
    acc1_id = generate_id()

    accounts = [
        {
            "id": acc1_id,
            "userId": user_id,
            "accountNumber": "KZ44 1234 5678 9000",
            "accountName": "Основной счет",
            "accountType": "Checking",
            "balance": 150000.0,
            "currency": "KZT",
            "isActive": True,
            "createdAt": now_iso(),
            "updatedAt": now_iso()
        }
    ]
    await db.accounts.insert_many(accounts)

    card = {
        "id": generate_id(),
        "userId": user_id,
        "accountId": acc1_id,
        "cardNumber": "4400 1122 3344 5566",
        "cardHolderName": user_name.upper(),
        "expiryDate": "12/28",
        "cvv": "123",
        "cardType": "Visa",
        "status": "active",
        "cardColor": "0xFF1E1E1E",
        "createdAt": now_iso(),
        "updatedAt": now_iso()
    }
    await db.cards.insert_one(card)


@app.post("/auth/register", response_model=Token)
async def register(user_data: UserCreate):
    if await db.users.find_one({"email": user_data.email}):
        raise HTTPException(status_code=400, detail="Email already registered")

    if await db.users.find_one({"iin": user_data.iin}):
        raise HTTPException(status_code=400, detail="IIN already registered")

    user_id = generate_id()
    now = now_iso()

    new_user = {
        "id": user_id,
        "firstName": user_data.firstName,
        "surname": user_data.surname,
        "patronymic": user_data.patronymic,
        "iin": user_data.iin,
        "email": user_data.email,
        "phone": user_data.phone,
        "avatarUrl": None,
        "hashed_password": get_password_hash(user_data.password),
        "createdAt": now,
        "updatedAt": now
    }

    await db.users.insert_one(new_user)
    full_name = f"{user_data.firstName} {user_data.surname}"
    await seed_user_data(user_id, full_name)

    token = create_access_token(data={"sub": new_user["email"]})
    return {"token": token, "user": UserResponse(**new_user)}


@app.post("/auth/login")
async def login(data: dict = Body(...)):
    email = data.get("email")
    password = data.get("password")

    user = await db.users.find_one({"email": email})
    if not user or not verify_password(password, user["hashed_password"]):
        raise HTTPException(status_code=401, detail="Invalid credentials")

    token = create_access_token(data={"sub": user["email"]})
    return {"token": token, "user": UserResponse(**user)}


@app.get("/users/me", response_model=UserResponse)
async def read_users_me(current_user: UserResponse = Depends(get_current_user)):
    return current_user


@app.post("/users/search")
async def search_user_by_phone(
        req: UserSearchRequest,
        current_user: UserResponse = Depends(get_current_user)
):
    clean_phone = "".join(filter(str.isdigit, req.phone))
    search_phone = clean_phone
    if len(clean_phone) == 11 and clean_phone.startswith('7'):
        search_phone = '8' + clean_phone[1:]
    elif len(clean_phone) == 10:
        search_phone = '8' + clean_phone

    print(f"DEBUG SEARCH: {search_phone}")

    user = await db.users.find_one({"phone": search_phone})

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if user["id"] == current_user.id:
        raise HTTPException(status_code=400, detail="You cannot transfer to yourself")

    return {
        "firstName": user["firstName"],
        "surname": user["surname"],
        "patronymic": user.get("patronymic")
    }



@app.get("/accounts", response_model=List[BankAccount])
async def get_accounts(current_user: UserResponse = Depends(get_current_user)):
    accounts = await db.accounts.find({"userId": current_user.id}).to_list(100)
    return accounts


@app.get("/accounts/{account_id}", response_model=BankAccount)
async def get_account_detail(account_id: str, current_user: UserResponse = Depends(get_current_user)):
    account = await db.accounts.find_one({"id": account_id, "userId": current_user.id})
    if not account:
        raise HTTPException(status_code=404, detail="Account not found")
    return account



@app.get("/cards", response_model=List[Card])
async def get_cards(current_user: UserResponse = Depends(get_current_user)):
    cards = await db.cards.find({"userId": current_user.id}).to_list(100)
    return cards



@app.get("/transactions", response_model=List[Transaction])
async def get_transactions(current_user: UserResponse = Depends(get_current_user)):
    cursor = db.transactions.find({"userId": current_user.id}).sort("transactionDate", -1)
    return await cursor.to_list(100)


@app.post("/transfers/card")
async def transfer_to_card(
        req: TransferRequest,
        current_user: UserResponse = Depends(get_current_user)
):
    account = await db.accounts.find_one({"id": req.accountId, "userId": current_user.id})
    if not account:
        raise HTTPException(status_code=404, detail="Account not found")

    if account["balance"] < req.amount:
        raise HTTPException(status_code=400, detail="Insufficient funds")

    now = now_iso()

    await db.accounts.update_one(
        {"id": req.accountId},
        {"$inc": {"balance": -req.amount}, "$set": {"updatedAt": now}}
    )

    transaction = {
        "id": generate_id(),
        "userId": current_user.id,
        "accountId": req.accountId,
        "type": "transfer",
        "category": "Transfer",
        "amount": -req.amount,
        "currency": account["currency"],
        "recipient": req.cardNumber,
        "description": req.description or f"Transfer to {req.cardNumber}",
        "status": "completed",
        "transactionDate": now,
        "createdAt": now,
        "updatedAt": now
    }
    await db.transactions.insert_one(transaction)

    return {"status": "success", "transactionId": transaction["id"]}


@app.post("/transfers/phone")
async def transfer_by_phone(
        req: TransferByPhoneRequest,
        current_user: UserResponse = Depends(get_current_user)
):
    source_account = await db.accounts.find_one({"id": req.accountId, "userId": current_user.id})
    if not source_account:
        raise HTTPException(status_code=404, detail="Source account not found")

    if source_account["balance"] < req.amount:
        raise HTTPException(status_code=400, detail="Insufficient funds")

    clean_phone = "".join(filter(str.isdigit, req.phoneNumber))
    search_phone = clean_phone

    if len(clean_phone) == 11 and clean_phone.startswith('7'):
        search_phone = '8' + clean_phone[1:]
    elif len(clean_phone) == 10:
        search_phone = '8' + clean_phone

    print(f"DEBUG: Transfer to phone: {search_phone}")

    recipient_user = await db.users.find_one({"phone": search_phone})
    if not recipient_user:
        raise HTTPException(status_code=404, detail=f"User with phone {search_phone} not found")

    if recipient_user["id"] == current_user.id:
        raise HTTPException(status_code=400, detail="Cannot transfer to yourself")

    recipient_account = await db.accounts.find_one({"userId": recipient_user["id"], "isActive": True})
    if not recipient_account:
        raise HTTPException(status_code=400, detail="Recipient has no active accounts")

    now = now_iso()

    await db.accounts.update_one(
        {"id": req.accountId},
        {"$inc": {"balance": -req.amount}, "$set": {"updatedAt": now}}
    )

    await db.accounts.update_one(
        {"id": recipient_account["id"]},
        {"$inc": {"balance": req.amount}, "$set": {"updatedAt": now}}
    )

    transaction_out = {
        "id": generate_id(),
        "userId": current_user.id,
        "accountId": req.accountId,
        "type": "transfer_out",
        "category": "Transfer",
        "amount": -req.amount,
        "currency": source_account["currency"],
        "recipient": f"{recipient_user['firstName']} {recipient_user['surname']}",
        "description": req.description or f"Transfer to {search_phone}",
        "status": "completed",
        "transactionDate": now,
        "createdAt": now,
        "updatedAt": now
    }
    await db.transactions.insert_one(transaction_out)

    transaction_in = {
        "id": generate_id(),
        "userId": recipient_user["id"],
        "accountId": recipient_account["id"],
        "type": "transfer_in",
        "category": "Transfer",
        "amount": req.amount,
        "currency": recipient_account["currency"],
        "recipient": f"{current_user.firstName} {current_user.surname}",
        "description": "Incoming transfer via phone",
        "status": "completed",
        "transactionDate": now,
        "createdAt": now,
        "updatedAt": now
    }
    await db.transactions.insert_one(transaction_in)

    return {"status": "success", "transactionId": transaction_out["id"]}


@app.post("/support/chat")
async def support_chat(
        req: SupportChatRequest
):
    if not openai_client:
        raise HTTPException(
            status_code=500,
            detail="OpenAI client is not initialized. Check server logs."
        )

    try:
        system_prompt = ""
        if req.language == 'kk':
            system_prompt = "Сіз Veridian банкінің пайдалы виртуалды көмекшісісіз. Жауаптарыңыз қысқа, нақты және қазақ тілінде болсын."
        elif req.language == 'en':
            system_prompt = "You are a helpful virtual assistant for Veridian Bank. Keep your answers concise and in English."
        else:
            system_prompt = "Ты — полезный виртуальный помощник банка Veridian. Отвечай кратко, по делу и на русском языке."

        print(f"DEBUG: Sending request to OpenAI: {req.message}")

        chat_completion = await openai_client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": req.message}
            ],
            max_tokens=150,
            temperature=0.7,
        )

        reply_text = chat_completion.choices[0].message.content
        print(f"DEBUG: OpenAI response: {reply_text}")

        return {"reply": reply_text}

    except Exception as e:
        print(f"ERROR: OpenAI API failed: {e}")
        error_msg = {
            'ru': "Извините, сейчас я не могу ответить. Попробуйте позже.",
            'kk': "Кешіріңіз, қазір жауап бере алмаймын. Кейінірек көріңіз.",
            'en': "Sorry, I cannot answer right now. Try again later."
        }
        return {"reply": error_msg.get(req.language, error_msg['ru'])}


@app.get("/bills", response_model=List[Bill])
async def get_bills(current_user: UserResponse = Depends(get_current_user)):
    return await db.bills.find({"userId": current_user.id}).to_list(100)


@app.get("/loans", response_model=List[Loan])
async def get_loans(current_user: UserResponse = Depends(get_current_user)):
    return await db.loans.find({"userId": current_user.id}).to_list(100)


@app.get("/recipients", response_model=List[TransferRecipient])
async def get_recipients(current_user: UserResponse = Depends(get_current_user)):
    return await db.recipients.find({"userId": current_user.id}).to_list(100)


@app.post("/recipients", response_model=TransferRecipient)
async def add_recipient(
        data: dict = Body(...),
        current_user: UserResponse = Depends(get_current_user)
):
    now = now_iso()
    recipient = {
        "id": generate_id(),
        "userId": current_user.id,
        "name": data.get("name", "Unknown"),
        "accountNumber": data.get("accountNumber", ""),
        "bankName": data.get("bankName", "Other Bank"),
        "recipientType": data.get("recipientType", "external"),
        "isFavorite": data.get("isFavorite", False),
        "createdAt": now,
        "updatedAt": now
    }
    await db.recipients.insert_one(recipient)
    return recipient


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)