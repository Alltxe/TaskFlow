import { Controller, Get, Res } from '@nestjs/common';
import { Response } from 'express';

/**
 * Служит файлами верификации для Android App Links и iOS Universal Links.
 *
 * Android: GET /.well-known/assetlinks.json
 *   - Настройте ANDROID_PACKAGE_NAME и ANDROID_SHA256_FINGERPRINT через .env
 *   - SHA256 fingerprint можно получить командой:
 *     keytool -list -v -keystore your.keystore -alias your-alias
 *
 * iOS: GET /.well-known/apple-app-site-association
 *   - Настройте IOS_TEAM_ID и IOS_BUNDLE_ID через .env
 *   - Файл автоматически связывает домен с вашим приложением
 */
@Controller('.well-known')
export class WellKnownController {
  @Get('assetlinks.json')
  assetLinks(@Res() res: Response) {
    const packageName = process.env.ANDROID_PACKAGE_NAME ?? 'com.taskflow.com';
    const sha256Fingerprint =
      process.env.ANDROID_SHA256_FINGERPRINT ??
      'AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99';

    res.setHeader('Content-Type', 'application/json');
    res.json([
      {
        relation: ['delegate_permission/common.handle_all_urls'],
        target: {
          namespace: 'android_app',
          package_name: packageName,
          sha256_cert_fingerprints: [sha256Fingerprint],
        },
      },
    ]);
  }

  @Get('apple-app-site-association')
  appleAppSiteAssociation(@Res() res: Response) {
    const teamId = process.env.IOS_TEAM_ID ?? 'XXXXXXXXXX';
    const bundleId = process.env.IOS_BUNDLE_ID ?? 'com.example.mobile';

    res.setHeader('Content-Type', 'application/json');
    res.json({
      applinks: {
        details: [
          {
            appIDs: [`${teamId}.${bundleId}`],
            components: [
              {
                '/': '/join/*',
                comment: 'Открывает экран присоединения к группе',
              },
            ],
          },
        ],
      },
    });
  }
}
