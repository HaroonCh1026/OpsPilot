from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "OpsPilot AI Service"

    model_config = SettingsConfigDict(
        env_prefix="OPSPILOT_AI_",
        env_file=".env",
        env_file_encoding="utf-8",
    )


settings = Settings()
