from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    firebase_credentials_path: str = ""
    firebase_project_id: str = ""
    openai_api_key: str = ""
    openai_model: str = "gpt-4o-mini"
    rate_limit_per_minute: int = 20


settings = Settings()
