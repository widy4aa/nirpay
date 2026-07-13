import { IsEmail, IsString, Length, Matches } from "class-validator";

export class LoginDto {
  @IsEmail()
  email: string;

  @IsString()
  @Length(6, 6)
  @Matches(/^[0-9]+$/, {
    message: "PIN must be exactly 6 digits",
  })
  pin: string;
}
