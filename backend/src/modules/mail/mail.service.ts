import { Injectable, Logger } from '@nestjs/common';
import { MailerService } from '@nestjs-modules/mailer';

@Injectable()
export class MailService {
  private readonly logger = new Logger(MailService.name);

  constructor(private mailerService: MailerService) {}

  async sendEmailVerificationCode(
    email: string,
    username: string,
    code: string,
  ): Promise<void> {
    const ttlMinutes =
      parseInt(process.env.EMAIL_VERIFICATION_CODE_TTL_MINUTES || '15', 10);

    try {
      await this.mailerService.sendMail({
        to: email,
        subject: 'Подтверждение email — TaskFlow',
        html: `
          <div style="font-family: sans-serif; max-width: 480px; margin: 0 auto;">
            <h2>Привет, ${username}!</h2>
            <p>Для подтверждения вашего email введите код:</p>
            <div style="
              font-size: 32px;
              font-weight: bold;
              letter-spacing: 8px;
              text-align: center;
              padding: 24px;
              background: #f4f4f4;
              border-radius: 8px;
              margin: 24px 0;
            ">${code}</div>
            <p style="color: #666; font-size: 14px;">
              Код действителен ${ttlMinutes} минут.<br>
              Если вы не регистрировались в TaskFlow — проигнорируйте это письмо.
            </p>
          </div>
        `,
      });
    } catch (err) {
      this.logger.warn(
        `Failed to send verification email to ${email}: ${err?.message}`,
      );
    }
  }

  async sendPasswordResetCode(
    email: string,
    username: string,
    code: string,
    ttlMinutes = 15,
  ): Promise<void> {
    try {
      await this.mailerService.sendMail({
        to: email,
        subject: 'Сброс пароля — TaskFlow',
        html: `
          <div style="font-family: sans-serif; max-width: 480px; margin: 0 auto;">
            <h2>Привет, ${username}!</h2>
            <p>Вы запросили сброс пароля. Введите код для подтверждения:</p>
            <div style="
              font-size: 32px;
              font-weight: bold;
              letter-spacing: 8px;
              text-align: center;
              padding: 24px;
              background: #f4f4f4;
              border-radius: 8px;
              margin: 24px 0;
            ">${code}</div>
            <p style="color: #666; font-size: 14px;">
              Код действителен ${ttlMinutes} минут.<br>
              Если вы не запрашивали сброс пароля — проигнорируйте это письмо.
            </p>
          </div>
        `,
      });
    } catch (err) {
      this.logger.warn(
        `Failed to send password reset email to ${email}: ${err?.message}`,
      );
    }
  }
}
