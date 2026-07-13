import {
  IsEmail,
  IsString,
  IsOptional,
  Length,
  Matches,
  IsIn,
} from "class-validator";

export class RegisterDto {
  @IsEmail()
  email: string;

  @IsString()
  @Matches(/^(\+62|62|0)8[1-9][0-9]{6,9}$/, {
    message: "Phone number must be a valid Indonesian number",
  })
  phone: string;

  @IsString()
  @Length(2, 100)
  fullName: string;

  @IsString()
  @Length(3, 20)
  @Matches(/^[a-zA-Z0-9_]+$/, {
    message: "Username must contain only letters, numbers, and underscores",
  })
  username: string;

  @IsString()
  @Length(6, 6)
  @Matches(/^[0-9]+$/, {
    message: "PIN must be exactly 6 digits",
  })
  pin: string;

  @IsString()
  publicKeyB64: string;

  @IsOptional()
  @IsString()
  @IsIn(["MALE", "FEMALE"])
  gender?: string;

  @IsOptional()
  @IsString()
  birthDate?: string;
}
