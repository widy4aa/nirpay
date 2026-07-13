import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
} from "@nestjs/common";
import { Observable } from "rxjs";
import { map } from "rxjs/operators";
import { ApiResponse } from "../interfaces/api-response.interface";

@Injectable()
export class TransformResponseInterceptor<T> implements NestInterceptor<
  T,
  ApiResponse<T>
> {
  intercept(
    context: ExecutionContext,
    next: CallHandler,
  ): Observable<ApiResponse<T>> {
    return next.handle().pipe(
      map((data: unknown) => {
        if (
          data &&
          typeof data === "object" &&
          "success" in data &&
          ("data" in data || "message" in data)
        ) {
          return {
            ...(data as Record<string, unknown>),
            timestamp: new Date().toISOString(),
          } as unknown as ApiResponse<T>;
        }

        return {
          success: true,
          data: data as T,
          timestamp: new Date().toISOString(),
        } as ApiResponse<T>;
      }),
    );
  }
}
