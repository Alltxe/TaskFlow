import { ExtractJwt, Strategy } from 'passport-jwt';
import { PassportStrategy } from '@nestjs/passport';
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { AuthService, JwtPayload } from './auth.service';
import { JWT_CONFIG } from './auth.config';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private authService: AuthService) {
    super({
      jwtFromRequest: ExtractJwt.fromExtractors([
        ExtractJwt.fromAuthHeaderAsBearerToken(),
        // Также поддерживаем токен без префикса "Bearer "
        (request) => {
          const token = request?.headers?.authorization;
          if (token && !token.startsWith('Bearer ')) {
            return token;
          }
          return null;
        },
      ]),
      ignoreExpiration: false,
      secretOrKey: JWT_CONFIG.secret as string,
    });
  }

  /**
   * Валидация JWT payload и получение пользователя
   */
  async validate(payload: JwtPayload) {
    const user = await this.authService.validateUser(payload);
    
    if (!user) {
      throw new UnauthorizedException('User not found');
    }
    
    return user;
  }
}