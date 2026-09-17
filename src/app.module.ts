import { Module } from '@nestjs/common';
import { createObserveModule } from '@nestjs/observe';
import { AppController } from './app.controller.js';
import { AppService } from './app.service.js';
import { IamModule } from './modules/iam/iam.module.js';
import { OrganizationModule } from './modules/organization/organization.module.js';
import { MerchandisingModule } from './modules/merchandising/merchandising.module.js';
import { PlanningModule } from './modules/planning/planning.module.js';
import { CuttingModule } from './modules/cutting/cutting.module.js';
import { SewingModule } from './modules/sewing/sewing.module.js';
import { FinishingModule } from './modules/finishing/finishing.module.js';
import { QualityModule } from './modules/quality/quality.module.js';
import { InventoryModule } from './modules/inventory/inventory.module.js';
import { ProcurementModule } from './modules/procurement/procurement.module.js';
import { SalesModule } from './modules/sales/sales.module.js';
import { AccountingModule } from './modules/accounting/accounting.module.js';
import { HrModule } from './modules/hr/hr.module.js';
import { ComplianceModule } from './modules/compliance/compliance.module.js';
import { ReportingModule } from './modules/reporting/reporting.module.js';
import { NotificationsModule } from './modules/notifications/notifications.module.js';
import { AiModule } from './modules/ai/ai.module.js';
import { HealthModule } from './health/health.module.js';

export const { ObserveModule, ObserveInstrument } = createObserveModule();

@Module({
  imports: [
    // Distributed tracing, auto-correlated logs, request/job metrics, error
    // telemetry, alarms, and more — out of the box. Sign up at https://observe.nestjs.com
    ObserveModule.forRoot({
      appKey: 'YOUR_APP_KEY',
      appSecret: 'YOUR_APP_SECRET',
      serviceId: 'forge-erp',
    }),
    IamModule,
    OrganizationModule,
    MerchandisingModule,
    PlanningModule,
    CuttingModule,
    SewingModule,
    FinishingModule,
    QualityModule,
    InventoryModule,
    ProcurementModule,
    SalesModule,
    AccountingModule,
    HrModule,
    ComplianceModule,
    ReportingModule,
    NotificationsModule,
    AiModule,
    HealthModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
