import { IsEmail, IsString, IsIn, Length, Matches } from "class-validator";

export class SendOtpDto {
  @IsEmail()
  email: string;

  @IsString()
  phone: string;

  @IsString()
  @IsIn(["register", "reset"])
  type: string;
}

export class VerifyOtpDto {
  @IsString()
  otpId: string;

  @IsString()
  @Length(6, 6)
  @Matches(/^[0-9]+$/, {
    message: "OTP must be exactly 6 digits",
  })
  otpCode: string;
}
