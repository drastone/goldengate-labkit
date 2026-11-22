import pandas as pd
import faker

# Faker를 사용하여 가짜 고객 데이터 생성
fake = faker.Faker()

# 200명의 샘플 고객 데이터 생성
data = []
for _ in range(200):
    name = fake.name()
    email = fake.email()
    phone = fake.phone_number()
    address = fake.address().replace("\n", ", ")
    data.append([name, email, phone, address])

# DataFrame 생성
df = pd.DataFrame(data, columns=["Name", "Email", "Phone", "Address"])

# CSV 파일로 저장
df.to_csv("sample_customers.csv", index=False)

