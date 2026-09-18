-- Enable extensions required by UUID defaults and AI embeddings.
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "vector";

-- CreateEnum
CREATE TYPE "user_status_enum" AS ENUM ('active', 'inactive', 'locked');

-- CreateEnum
CREATE TYPE "style_status_enum" AS ENUM ('draft', 'costed', 'approved', 'active', 'discontinued');

-- CreateEnum
CREATE TYPE "sample_type_enum" AS ENUM ('proto', 'fit', 'pp', 'shipment_photo');

-- CreateEnum
CREATE TYPE "decision_status_enum" AS ENUM ('pending', 'approved', 'rejected', 'revise');

-- CreateEnum
CREATE TYPE "order_status_enum" AS ENUM ('draft', 'confirmed', 'in_production', 'partially_shipped', 'shipped', 'closed', 'cancelled');

-- CreateEnum
CREATE TYPE "milestone_status_enum" AS ENUM ('pending', 'at_risk', 'delayed', 'completed');

-- CreateEnum
CREATE TYPE "scan_type_enum" AS ENUM ('in', 'out');

-- CreateEnum
CREATE TYPE "inspection_result_enum" AS ENUM ('pass', 'fail');

-- CreateEnum
CREATE TYPE "severity_enum" AS ENUM ('critical', 'major', 'minor');

-- CreateEnum
CREATE TYPE "movement_direction_enum" AS ENUM ('in', 'out');

-- CreateEnum
CREATE TYPE "movement_type_enum" AS ENUM ('receipt', 'issue', 'transfer', 'adjustment');

-- CreateEnum
CREATE TYPE "costing_method_enum" AS ENUM ('fifo', 'weighted_average');

-- CreateEnum
CREATE TYPE "po_status_enum" AS ENUM ('draft', 'sent', 'partially_received', 'received', 'closed', 'cancelled');

-- CreateEnum
CREATE TYPE "match_status_enum" AS ENUM ('pending', 'matched', 'discrepancy', 'approved');

-- CreateEnum
CREATE TYPE "ap_ar_status_enum" AS ENUM ('open', 'partially_paid', 'paid', 'overdue');

-- CreateEnum
CREATE TYPE "shipment_status_enum" AS ENUM ('booked', 'loaded', 'shipped', 'delivered', 'cancelled');

-- CreateEnum
CREATE TYPE "payroll_status_enum" AS ENUM ('draft', 'processing', 'approved', 'paid');

-- CreateEnum
CREATE TYPE "wage_type_enum" AS ENUM ('monthly', 'daily', 'piece_rate');

-- CreateEnum
CREATE TYPE "leave_status_enum" AS ENUM ('pending', 'approved', 'rejected', 'cancelled');

-- CreateEnum
CREATE TYPE "cap_status_enum" AS ENUM ('open', 'in_progress', 'closed', 'overdue');

-- CreateEnum
CREATE TYPE "approval_status_enum" AS ENUM ('pending', 'approved', 'rejected');

-- CreateEnum
CREATE TYPE "material_type_enum" AS ENUM ('fabric', 'trim');

-- CreateEnum
CREATE TYPE "stock_item_type_enum" AS ENUM ('fabric', 'trim', 'finished_good');

-- CreateEnum
CREATE TYPE "account_type_enum" AS ENUM ('asset', 'liability', 'equity', 'income', 'expense');

-- CreateEnum
CREATE TYPE "journal_source_enum" AS ENUM ('sales_invoice', 'supplier_invoice', 'payroll', 'stock_adjustment', 'manual');

-- CreateEnum
CREATE TYPE "journal_status_enum" AS ENUM ('draft', 'posted', 'reversed');

-- CreateEnum
CREATE TYPE "attendance_status_enum" AS ENUM ('present', 'absent', 'leave', 'holiday', 'weekend');

-- CreateEnum
CREATE TYPE "attendance_source_enum" AS ENUM ('manual', 'biometric', 'rfid');

-- CreateEnum
CREATE TYPE "supplier_type_enum" AS ENUM ('local', 'import');

-- CreateEnum
CREATE TYPE "warehouse_type_enum" AS ENUM ('rm', 'wip', 'fg', 'other');

-- CreateEnum
CREATE TYPE "component_type_enum" AS ENUM ('earning', 'deduction');

-- CreateEnum
CREATE TYPE "payment_type_enum" AS ENUM ('payable', 'receivable');

-- CreateEnum
CREATE TYPE "party_type_enum" AS ENUM ('supplier', 'buyer');

-- CreateEnum
CREATE TYPE "requisition_source_enum" AS ENUM ('mrp', 'manual');

-- CreateEnum
CREATE TYPE "inspection_stage_enum" AS ENUM ('inline', 'endline', 'aql_final');

-- CreateEnum
CREATE TYPE "offset_reference_enum" AS ENUM ('order_confirmation', 'ship_date');

-- CreateEnum
CREATE TYPE "transfer_status_enum" AS ENUM ('in_transit', 'received', 'cancelled');

-- CreateEnum
CREATE TYPE "rework_status_enum" AS ENUM ('pending', 'in_progress', 'completed', 'scrapped');

-- CreateTable
CREATE TABLE "tenants" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "name" VARCHAR(200) NOT NULL,
    "slug" VARCHAR(100) NOT NULL,
    "subscription_plan" VARCHAR(50) NOT NULL DEFAULT 'standard',
    "status" "user_status_enum" NOT NULL DEFAULT 'active',
    "default_locale" VARCHAR(10) NOT NULL DEFAULT 'en',
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "tenants_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "companies" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "name" VARCHAR(200) NOT NULL,
    "legal_name" VARCHAR(200),
    "registration_no" VARCHAR(100),
    "tax_id" VARCHAR(100),
    "base_currency" CHAR(3) NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "companies_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "factories" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "company_id" UUID NOT NULL,
    "name" VARCHAR(200) NOT NULL,
    "code" VARCHAR(30) NOT NULL,
    "type" VARCHAR(50),
    "address" VARCHAR(255),
    "city" VARCHAR(100),
    "country" VARCHAR(100),
    "timezone" VARCHAR(50) NOT NULL DEFAULT 'Asia/Dhaka',
    "is_active" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "factories_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "branches" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "company_id" UUID NOT NULL,
    "factory_id" UUID,
    "name" VARCHAR(200) NOT NULL,
    "branch_type" VARCHAR(50),
    "address" TEXT,

    CONSTRAINT "branches_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "departments" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "factory_id" UUID NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "parent_department_id" UUID,

    CONSTRAINT "departments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "email" VARCHAR(320) NOT NULL,
    "username" VARCHAR(100),
    "password_hash" VARCHAR(255) NOT NULL,
    "status" "user_status_enum" NOT NULL DEFAULT 'active',
    "mfa_enabled" BOOLEAN NOT NULL DEFAULT false,
    "password_changed_at" TIMESTAMPTZ(6),
    "last_login_at" TIMESTAMPTZ(6),
    "failed_login_count" INTEGER NOT NULL DEFAULT 0,
    "is_deleted" BOOLEAN NOT NULL DEFAULT false,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "mfa_factors" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" UUID NOT NULL,
    "factor_type" VARCHAR(30) NOT NULL,
    "secret_encrypted" TEXT,
    "is_verified" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "mfa_factors_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "roles" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID,
    "name" VARCHAR(100) NOT NULL,
    "is_system_role" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "roles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "permissions" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "code" VARCHAR(100) NOT NULL,
    "module" VARCHAR(50) NOT NULL,
    "action" VARCHAR(50) NOT NULL,
    "description" TEXT,

    CONSTRAINT "permissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "role_permissions" (
    "role_id" UUID NOT NULL,
    "permission_id" UUID NOT NULL,

    CONSTRAINT "role_permissions_pkey" PRIMARY KEY ("role_id","permission_id")
);

-- CreateTable
CREATE TABLE "user_roles" (
    "user_id" UUID NOT NULL,
    "role_id" UUID NOT NULL,
    "factory_id" UUID NOT NULL,

    CONSTRAINT "user_roles_pkey" PRIMARY KEY ("user_id","role_id","factory_id")
);

-- CreateTable
CREATE TABLE "user_factory_access" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" UUID NOT NULL,
    "factory_id" UUID NOT NULL,
    "is_primary" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "user_factory_access_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sessions" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "ip_address" inet,
    "user_agent" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "revoked_at" TIMESTAMPTZ(6),

    CONSTRAINT "sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "refresh_tokens" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "session_id" UUID NOT NULL,
    "token_hash" VARCHAR(255) NOT NULL,
    "issued_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "revoked_at" TIMESTAMPTZ(6),
    "replaced_by_token_id" UUID,

    CONSTRAINT "refresh_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_logs" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "user_id" UUID,
    "action" VARCHAR(100) NOT NULL,
    "entity_type" VARCHAR(100),
    "entity_id" UUID,
    "before_data" JSONB,
    "after_data" JSONB,
    "ip_address" inet,
    "user_agent" TEXT,
    "occurred_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "buyers" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "company_id" UUID NOT NULL,
    "name" VARCHAR(200) NOT NULL,
    "code" VARCHAR(50) NOT NULL,
    "payment_terms" VARCHAR(200),
    "shipping_preferences" JSONB,
    "compliance_requirements" JSONB,
    "default_aql_sampling_plan_id" UUID,
    "is_active" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "buyers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "buyer_contacts" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "buyer_id" UUID NOT NULL,
    "name" VARCHAR(150) NOT NULL,
    "designation" VARCHAR(100),
    "email" VARCHAR(320),
    "phone" VARCHAR(30),

    CONSTRAINT "buyer_contacts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "styles" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "company_id" UUID NOT NULL,
    "buyer_id" UUID NOT NULL,
    "style_code" VARCHAR(100) NOT NULL,
    "name" VARCHAR(200),
    "description" TEXT,
    "category" VARCHAR(100),
    "season" VARCHAR(50),
    "size_range" VARCHAR(50),
    "status" "style_status_enum" NOT NULL DEFAULT 'draft',

    CONSTRAINT "styles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "style_sizes" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "style_id" UUID NOT NULL,
    "size_name" VARCHAR(20) NOT NULL,
    "sort_order" SMALLINT NOT NULL,

    CONSTRAINT "style_sizes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "style_colors" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "style_id" UUID NOT NULL,
    "color_name" VARCHAR(50) NOT NULL,
    "color_code" VARCHAR(20),

    CONSTRAINT "style_colors_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tech_packs" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "style_id" UUID NOT NULL,
    "version" INTEGER NOT NULL DEFAULT 1,
    "attachment_id" UUID,
    "construction_details" JSONB,
    "approved_by" UUID,
    "approved_at" TIMESTAMPTZ(6),

    CONSTRAINT "tech_packs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "boms" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "style_id" UUID NOT NULL,
    "version" INTEGER NOT NULL DEFAULT 1,
    "status" "approval_status_enum" NOT NULL DEFAULT 'pending',
    "effective_date" DATE,

    CONSTRAINT "boms_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "bom_items" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "bom_id" UUID NOT NULL,
    "material_type" "material_type_enum" NOT NULL,
    "fabric_id" UUID,
    "trim_id" UUID,
    "style_size_id" UUID,
    "consumption_per_garment" DECIMAL(14,4) NOT NULL,
    "uom_id" UUID NOT NULL,
    "wastage_pct" DECIMAL(6,3) NOT NULL DEFAULT 0,

    CONSTRAINT "bom_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "costing_sheets" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "style_id" UUID NOT NULL,
    "version" INTEGER NOT NULL DEFAULT 1,
    "fabric_cost" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "trim_cost" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "cm_cost" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "overhead_cost" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "commission_pct" DECIMAL(6,3) NOT NULL DEFAULT 0,
    "margin_pct" DECIMAL(6,3) NOT NULL DEFAULT 0,
    "fob_price" DECIMAL(14,2) NOT NULL,
    "currency" CHAR(3) NOT NULL,
    "status" "approval_status_enum" NOT NULL DEFAULT 'pending',

    CONSTRAINT "costing_sheets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "samples" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "style_id" UUID NOT NULL,
    "sample_type" "sample_type_enum" NOT NULL,
    "iteration_no" INTEGER NOT NULL DEFAULT 1,
    "status" "decision_status_enum" NOT NULL DEFAULT 'pending',
    "buyer_comments" TEXT,
    "requested_date" DATE,
    "submitted_date" DATE,
    "decision_date" DATE,
    "decided_by" VARCHAR(150),

    CONSTRAINT "samples_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sales_orders" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "company_id" UUID NOT NULL,
    "factory_id" UUID NOT NULL,
    "order_no" VARCHAR(50) NOT NULL,
    "buyer_id" UUID NOT NULL,
    "style_id" UUID NOT NULL,
    "order_date" DATE NOT NULL,
    "ship_date" DATE NOT NULL,
    "incoterm" VARCHAR(10),
    "currency" CHAR(3) NOT NULL,
    "total_quantity" INTEGER NOT NULL DEFAULT 0,
    "status" "order_status_enum" NOT NULL DEFAULT 'draft',

    CONSTRAINT "sales_orders_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "order_lines" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "order_id" UUID NOT NULL,
    "style_color_id" UUID NOT NULL,
    "style_size_id" UUID NOT NULL,
    "sku_code" VARCHAR(100) NOT NULL,
    "quantity" INTEGER NOT NULL,
    "unit_price" DECIMAL(14,2) NOT NULL,
    "status" "order_status_enum" NOT NULL DEFAULT 'confirmed',

    CONSTRAINT "order_lines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "order_amendments" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "order_id" UUID NOT NULL,
    "field_changed" VARCHAR(50) NOT NULL,
    "old_value" TEXT,
    "new_value" TEXT,
    "reason" TEXT,
    "amended_by" UUID,
    "amended_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "order_amendments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "order_factory_splits" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "order_id" UUID NOT NULL,
    "factory_id" UUID NOT NULL,
    "quantity" INTEGER NOT NULL,

    CONSTRAINT "order_factory_splits_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tna_templates" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "is_default" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "tna_templates_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tna_template_milestones" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tna_template_id" UUID NOT NULL,
    "milestone_name" VARCHAR(100) NOT NULL,
    "sequence" SMALLINT NOT NULL,
    "offset_days" INTEGER NOT NULL,
    "offset_reference" "offset_reference_enum" NOT NULL,
    "buffer_days" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "tna_template_milestones_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tna_calendars" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "order_id" UUID NOT NULL,
    "tna_template_id" UUID NOT NULL,
    "generated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "tna_calendars_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tna_milestones" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tna_calendar_id" UUID NOT NULL,
    "milestone_name" VARCHAR(100) NOT NULL,
    "sequence" SMALLINT NOT NULL,
    "planned_date" DATE NOT NULL,
    "actual_date" DATE,
    "status" "milestone_status_enum" NOT NULL DEFAULT 'pending',
    "responsible_user_id" UUID,
    "buffer_days" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "tna_milestones_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "units_of_measure" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID,
    "code" VARCHAR(10) NOT NULL,
    "name" VARCHAR(50) NOT NULL,
    "category" VARCHAR(30),

    CONSTRAINT "units_of_measure_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "uom_conversions" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "from_uom_id" UUID NOT NULL,
    "to_uom_id" UUID NOT NULL,
    "multiply_factor" DECIMAL(18,8) NOT NULL,

    CONSTRAINT "uom_conversions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "fabrics" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "company_id" UUID NOT NULL,
    "fabric_code" VARCHAR(50) NOT NULL,
    "name" VARCHAR(150) NOT NULL,
    "composition" VARCHAR(200),
    "gsm" DECIMAL(8,2),
    "width_cm" DECIMAL(8,2),
    "shrinkage_pct" DECIMAL(6,3),
    "color" VARCHAR(50),
    "dye_lot" VARCHAR(50),
    "default_supplier_id" UUID,
    "uom_id" UUID NOT NULL,
    "standard_cost" DECIMAL(14,4),
    "is_active" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "fabrics_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "trims" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "company_id" UUID NOT NULL,
    "trim_code" VARCHAR(50) NOT NULL,
    "name" VARCHAR(150) NOT NULL,
    "category" VARCHAR(50),
    "default_supplier_id" UUID,
    "uom_id" UUID NOT NULL,
    "standard_cost" DECIMAL(14,4),
    "is_active" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "trims_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "supplier_materials" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "supplier_id" UUID NOT NULL,
    "material_type" "material_type_enum" NOT NULL,
    "fabric_id" UUID,
    "trim_id" UUID,
    "supplier_material_code" VARCHAR(50),
    "lead_time_days" INTEGER,
    "moq" DECIMAL(14,3),
    "price" DECIMAL(14,4),
    "currency" CHAR(3),

    CONSTRAINT "supplier_materials_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "production_lines" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "factory_id" UUID NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "code" VARCHAR(30) NOT NULL,
    "floor" VARCHAR(50),
    "allocated_sam_capacity_per_day" DECIMAL(10,2) NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "production_lines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "line_capacity_plans" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "production_line_id" UUID NOT NULL,
    "plan_date" DATE NOT NULL,
    "available_minutes" DECIMAL(10,2) NOT NULL,
    "planned_sam_minutes" DECIMAL(10,2) NOT NULL DEFAULT 0,
    "efficiency_target_pct" DECIMAL(6,3),

    CONSTRAINT "line_capacity_plans_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "line_bookings" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "order_id" UUID NOT NULL,
    "production_line_id" UUID NOT NULL,
    "booked_date" DATE NOT NULL,
    "planned_quantity" INTEGER NOT NULL,
    "planned_sam_minutes" DECIMAL(12,2) NOT NULL,

    CONSTRAINT "line_bookings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "daily_production_plans" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "factory_id" UUID NOT NULL,
    "plan_date" DATE NOT NULL,
    "production_line_id" UUID NOT NULL,
    "order_id" UUID NOT NULL,
    "department" VARCHAR(30) NOT NULL,
    "planned_quantity" INTEGER NOT NULL,

    CONSTRAINT "daily_production_plans_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "mrp_requirements" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "order_id" UUID NOT NULL,
    "material_type" "material_type_enum" NOT NULL,
    "fabric_id" UUID,
    "trim_id" UUID,
    "required_qty" DECIMAL(14,3) NOT NULL,
    "available_qty" DECIMAL(14,3) NOT NULL DEFAULT 0,
    "ordered_qty" DECIMAL(14,3) NOT NULL DEFAULT 0,
    "shortage_qty" DECIMAL(14,3) NOT NULL DEFAULT 0,
    "calculated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "mrp_requirements_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "fabric_issues" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "factory_id" UUID NOT NULL,
    "order_id" UUID NOT NULL,
    "warehouse_id" UUID NOT NULL,
    "issue_no" VARCHAR(50) NOT NULL,
    "issued_date" DATE NOT NULL,
    "issued_by" UUID,
    "status" VARCHAR(20) NOT NULL DEFAULT 'issued',

    CONSTRAINT "fabric_issues_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "fabric_issue_items" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "fabric_issue_id" UUID NOT NULL,
    "fabric_id" UUID NOT NULL,
    "stock_lot_id" UUID NOT NULL,
    "quantity_issued" DECIMAL(14,3) NOT NULL,
    "uom_id" UUID NOT NULL,

    CONSTRAINT "fabric_issue_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "markers" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "style_id" UUID NOT NULL,
    "marker_no" VARCHAR(50) NOT NULL,
    "size_ratio" JSONB NOT NULL,
    "marker_length" DECIMAL(10,3) NOT NULL,
    "marker_efficiency_pct" DECIMAL(6,3) NOT NULL,
    "ply_count_planned" INTEGER,
    "created_by" UUID,

    CONSTRAINT "markers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "lays" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "marker_id" UUID NOT NULL,
    "cutting_order_id" UUID,
    "ply_count_actual" INTEGER NOT NULL,
    "planned_consumption" DECIMAL(14,3) NOT NULL,
    "fabric_consumed_actual" DECIMAL(14,3) NOT NULL,
    "variance_pct" DECIMAL(6,3) NOT NULL,
    "lay_date" DATE NOT NULL,

    CONSTRAINT "lays_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "cutting_orders" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "factory_id" UUID NOT NULL,
    "order_id" UUID NOT NULL,
    "marker_id" UUID NOT NULL,
    "cutting_order_no" VARCHAR(50) NOT NULL,
    "planned_quantity" INTEGER NOT NULL,
    "cut_ratio_pct" DECIMAL(6,3),
    "status" VARCHAR(20) NOT NULL DEFAULT 'open',

    CONSTRAINT "cutting_orders_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "cut_bundles" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "cutting_order_id" UUID NOT NULL,
    "bundle_no" VARCHAR(50) NOT NULL,
    "style_color_id" UUID NOT NULL,
    "style_size_id" UUID NOT NULL,
    "quantity" INTEGER NOT NULL,
    "status" VARCHAR(30) NOT NULL DEFAULT 'cut',

    CONSTRAINT "cut_bundles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "fabric_relaxation_checks" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "lay_id" UUID NOT NULL,
    "checked_by" UUID,
    "shade_band_result" VARCHAR(30),
    "relaxation_hours" DECIMAL(6,2),
    "notes" TEXT,
    "checked_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "fabric_relaxation_checks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "operation_bulletins" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "style_id" UUID NOT NULL,
    "version" INTEGER NOT NULL DEFAULT 1,
    "is_active" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "operation_bulletins_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "operation_bulletin_lines" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "operation_bulletin_id" UUID NOT NULL,
    "operation_seq" SMALLINT NOT NULL,
    "operation_name" VARCHAR(150) NOT NULL,
    "machine_type" VARCHAR(50),
    "sam_value" DECIMAL(8,4) NOT NULL,

    CONSTRAINT "operation_bulletin_lines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "line_balance_plans" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "operation_bulletin_id" UUID NOT NULL,
    "production_line_id" UUID NOT NULL,
    "order_id" UUID NOT NULL,
    "effective_date" DATE NOT NULL,
    "target_efficiency_pct" DECIMAL(6,3),

    CONSTRAINT "line_balance_plans_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "line_balance_assignments" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "line_balance_plan_id" UUID NOT NULL,
    "operation_bulletin_line_id" UUID NOT NULL,
    "operator_employee_id" UUID,
    "machine_no" VARCHAR(30),
    "assigned_operators_count" SMALLINT NOT NULL DEFAULT 1,

    CONSTRAINT "line_balance_assignments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "bundle_scans" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "cut_bundle_id" UUID NOT NULL,
    "operation_bulletin_line_id" UUID NOT NULL,
    "production_line_id" UUID NOT NULL,
    "operator_employee_id" UUID,
    "scan_type" "scan_type_enum" NOT NULL,
    "device_local_timestamp" TIMESTAMPTZ(6) NOT NULL,
    "server_timestamp" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "synced_offline" BOOLEAN NOT NULL DEFAULT false,
    "client_scan_uuid" UUID NOT NULL,

    CONSTRAINT "bundle_scans_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "hourly_production_records" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "production_line_id" UUID NOT NULL,
    "order_id" UUID NOT NULL,
    "record_date" DATE NOT NULL,
    "hour_slot" SMALLINT NOT NULL,
    "quantity_produced" INTEGER NOT NULL DEFAULT 0,
    "available_minutes" DECIMAL(8,2) NOT NULL,
    "produced_sam_minutes" DECIMAL(10,2) NOT NULL,
    "efficiency_pct" DECIMAL(6,3),

    CONSTRAINT "hourly_production_records_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "downtime_reasons" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "code" VARCHAR(30) NOT NULL,
    "description" VARCHAR(150) NOT NULL,

    CONSTRAINT "downtime_reasons_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "downtime_logs" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "production_line_id" UUID NOT NULL,
    "downtime_reason_id" UUID NOT NULL,
    "record_date" DATE NOT NULL,
    "hour_slot" SMALLINT,
    "duration_minutes" DECIMAL(8,2) NOT NULL,
    "notes" TEXT,

    CONSTRAINT "downtime_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "piece_rate_outputs" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "operator_employee_id" UUID NOT NULL,
    "order_id" UUID NOT NULL,
    "operation_bulletin_line_id" UUID NOT NULL,
    "record_date" DATE NOT NULL,
    "quantity" INTEGER NOT NULL,
    "rate_per_piece" DECIMAL(10,4) NOT NULL,
    "incentive_amount" DECIMAL(14,2) NOT NULL,

    CONSTRAINT "piece_rate_outputs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "finishing_checklists" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "order_id" UUID NOT NULL,
    "cut_bundle_id" UUID,
    "checklist_date" DATE NOT NULL,
    "thread_trimming_done" BOOLEAN NOT NULL DEFAULT false,
    "ironing_done" BOOLEAN NOT NULL DEFAULT false,
    "tagging_done" BOOLEAN NOT NULL DEFAULT false,
    "checked_by" UUID,
    "remarks" TEXT,

    CONSTRAINT "finishing_checklists_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "wash_recipes" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "style_id" UUID NOT NULL,
    "recipe_name" VARCHAR(100) NOT NULL,
    "chemical_details" JSONB,
    "temperature_celsius" DECIMAL(6,2),
    "duration_minutes" INTEGER,
    "target_shrinkage_pct" DECIMAL(6,3),
    "target_shade" VARCHAR(50),

    CONSTRAINT "wash_recipes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "wash_orders" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "order_id" UUID NOT NULL,
    "wash_recipe_id" UUID NOT NULL,
    "subcontractor_supplier_id" UUID,
    "quantity" INTEGER NOT NULL,
    "wash_date" DATE,
    "actual_shrinkage_pct" DECIMAL(6,3),
    "actual_shade_result" VARCHAR(50),
    "status" VARCHAR(20) NOT NULL DEFAULT 'pending',

    CONSTRAINT "wash_orders_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "packing_configs" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "order_id" UUID NOT NULL,
    "pieces_per_poly" SMALLINT NOT NULL DEFAULT 1,
    "polys_per_carton" SMALLINT NOT NULL DEFAULT 1,
    "assortment_ratio" JSONB,

    CONSTRAINT "packing_configs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "cartons" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "order_id" UUID NOT NULL,
    "packing_config_id" UUID NOT NULL,
    "carton_no" VARCHAR(50) NOT NULL,
    "gross_weight_kg" DECIMAL(8,3),
    "net_weight_kg" DECIMAL(8,3),
    "dimensions" VARCHAR(50),
    "barcode" VARCHAR(100),
    "status" VARCHAR(20) NOT NULL DEFAULT 'packed',

    CONSTRAINT "cartons_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "carton_items" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "carton_id" UUID NOT NULL,
    "style_color_id" UUID NOT NULL,
    "style_size_id" UUID NOT NULL,
    "quantity" INTEGER NOT NULL,

    CONSTRAINT "carton_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "defect_codes" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "code" VARCHAR(30) NOT NULL,
    "description" VARCHAR(200) NOT NULL,
    "default_severity" "severity_enum" NOT NULL,
    "category" VARCHAR(50),

    CONSTRAINT "defect_codes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "inline_inspections" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "order_id" UUID NOT NULL,
    "production_line_id" UUID NOT NULL,
    "operation_bulletin_line_id" UUID,
    "cut_bundle_id" UUID,
    "inspected_by" UUID NOT NULL,
    "inspection_datetime" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "quantity_checked" INTEGER NOT NULL,

    CONSTRAINT "inline_inspections_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "inline_inspection_defects" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "inline_inspection_id" UUID NOT NULL,
    "defect_code_id" UUID NOT NULL,
    "severity" "severity_enum" NOT NULL,
    "quantity" INTEGER NOT NULL,

    CONSTRAINT "inline_inspection_defects_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "endline_inspections" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "production_line_id" UUID NOT NULL,
    "order_id" UUID NOT NULL,
    "inspection_date" DATE NOT NULL,
    "quantity_checked" INTEGER NOT NULL,
    "dhu" DECIMAL(8,3) NOT NULL,
    "inspected_by" UUID,

    CONSTRAINT "endline_inspections_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "endline_inspection_defects" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "endline_inspection_id" UUID NOT NULL,
    "defect_code_id" UUID NOT NULL,
    "severity" "severity_enum" NOT NULL,
    "quantity" INTEGER NOT NULL,

    CONSTRAINT "endline_inspection_defects_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "aql_sampling_plans" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "standard" VARCHAR(50) NOT NULL DEFAULT 'ANSI/ASQC Z1.4',
    "inspection_level" VARCHAR(10) NOT NULL DEFAULT 'II',
    "aql_value" DECIMAL(5,2) NOT NULL DEFAULT 2.5,
    "is_default" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "aql_sampling_plans_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "aql_sampling_plan_rows" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "aql_sampling_plan_id" UUID NOT NULL,
    "lot_size_min" INTEGER NOT NULL,
    "lot_size_max" INTEGER NOT NULL,
    "sample_size" INTEGER NOT NULL,
    "accept_number" INTEGER NOT NULL,
    "reject_number" INTEGER NOT NULL,

    CONSTRAINT "aql_sampling_plan_rows_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "aql_inspection_reports" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "order_id" UUID NOT NULL,
    "aql_sampling_plan_id" UUID NOT NULL,
    "lot_size" INTEGER NOT NULL,
    "sample_size" INTEGER NOT NULL,
    "accept_number" INTEGER NOT NULL,
    "reject_number" INTEGER NOT NULL,
    "defects_found_critical" INTEGER NOT NULL DEFAULT 0,
    "defects_found_major" INTEGER NOT NULL DEFAULT 0,
    "defects_found_minor" INTEGER NOT NULL DEFAULT 0,
    "result" "inspection_result_enum" NOT NULL,
    "inspected_by" UUID NOT NULL,
    "inspection_date" DATE NOT NULL,
    "report_attachment_id" UUID,

    CONSTRAINT "aql_inspection_reports_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "aql_inspection_report_cartons" (
    "aql_inspection_report_id" UUID NOT NULL,
    "carton_id" UUID NOT NULL,

    CONSTRAINT "aql_inspection_report_cartons_pkey" PRIMARY KEY ("aql_inspection_report_id","carton_id")
);

-- CreateTable
CREATE TABLE "rework_orders" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "source_inspection_stage" "inspection_stage_enum" NOT NULL,
    "source_inline_inspection_id" UUID,
    "source_endline_inspection_id" UUID,
    "source_aql_report_id" UUID,
    "defect_code_id" UUID NOT NULL,
    "quantity" INTEGER NOT NULL,
    "assigned_to_employee_id" UUID,
    "status" "rework_status_enum" NOT NULL DEFAULT 'pending',
    "rework_completed_date" DATE,
    "re_inspection_result" "inspection_result_enum",

    CONSTRAINT "rework_orders_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "warehouses" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "factory_id" UUID NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "code" VARCHAR(30) NOT NULL,
    "type" "warehouse_type_enum" NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "warehouses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stock_items" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "item_type" "stock_item_type_enum" NOT NULL,
    "fabric_id" UUID,
    "trim_id" UUID,
    "style_id" UUID,
    "style_color_id" UUID,
    "style_size_id" UUID,
    "sku_code" VARCHAR(100) NOT NULL,
    "uom_id" UUID NOT NULL,
    "reorder_level" DECIMAL(14,3) NOT NULL DEFAULT 0,
    "reorder_qty" DECIMAL(14,3) NOT NULL DEFAULT 0,
    "costing_method" "costing_method_enum" NOT NULL DEFAULT 'weighted_average',

    CONSTRAINT "stock_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stock_lots" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "stock_item_id" UUID NOT NULL,
    "warehouse_id" UUID NOT NULL,
    "lot_no" VARCHAR(50) NOT NULL,
    "dye_lot" VARCHAR(50),
    "quantity_on_hand" DECIMAL(14,3) NOT NULL DEFAULT 0,
    "unit_cost" DECIMAL(14,4) NOT NULL DEFAULT 0,
    "received_date" DATE,

    CONSTRAINT "stock_lots_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stock_movements" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "stock_item_id" UUID NOT NULL,
    "warehouse_id" UUID NOT NULL,
    "stock_lot_id" UUID,
    "movement_type" "movement_type_enum" NOT NULL,
    "direction" "movement_direction_enum" NOT NULL,
    "quantity" DECIMAL(14,3) NOT NULL,
    "source_document_type" VARCHAR(50) NOT NULL,
    "source_document_id" UUID NOT NULL,
    "movement_date" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "stock_movements_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stock_transfers" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "from_warehouse_id" UUID NOT NULL,
    "to_warehouse_id" UUID NOT NULL,
    "stock_item_id" UUID NOT NULL,
    "stock_lot_id" UUID,
    "quantity" DECIMAL(14,3) NOT NULL,
    "status" "transfer_status_enum" NOT NULL DEFAULT 'in_transit',
    "transfer_date" DATE NOT NULL,
    "received_date" DATE,

    CONSTRAINT "stock_transfers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stock_adjustments" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "stock_item_id" UUID NOT NULL,
    "warehouse_id" UUID NOT NULL,
    "stock_lot_id" UUID,
    "quantity_delta" DECIMAL(14,3) NOT NULL,
    "reason_code" VARCHAR(50) NOT NULL,
    "value_impact" DECIMAL(14,2) NOT NULL,
    "approval_status" "approval_status_enum" NOT NULL DEFAULT 'pending',
    "approved_by" UUID,
    "adjustment_date" DATE NOT NULL,

    CONSTRAINT "stock_adjustments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "suppliers" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "company_id" UUID NOT NULL,
    "name" VARCHAR(200) NOT NULL,
    "code" VARCHAR(50) NOT NULL,
    "supplier_type" "supplier_type_enum" NOT NULL DEFAULT 'local',
    "contact_person" VARCHAR(150),
    "email" VARCHAR(320),
    "phone" VARCHAR(30),
    "address" VARCHAR(255),
    "country" VARCHAR(100),
    "payment_terms" VARCHAR(200),
    "is_active" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "suppliers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "purchase_requisitions" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "factory_id" UUID NOT NULL,
    "requisition_no" VARCHAR(50) NOT NULL,
    "source" "requisition_source_enum" NOT NULL,
    "order_id" UUID,
    "requested_by" UUID NOT NULL,
    "status" "approval_status_enum" NOT NULL DEFAULT 'pending',
    "approved_by" UUID,

    CONSTRAINT "purchase_requisitions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "purchase_requisition_items" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "purchase_requisition_id" UUID NOT NULL,
    "material_type" "material_type_enum" NOT NULL,
    "fabric_id" UUID,
    "trim_id" UUID,
    "quantity" DECIMAL(14,3) NOT NULL,
    "uom_id" UUID NOT NULL,

    CONSTRAINT "purchase_requisition_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "purchase_orders" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "supplier_id" UUID NOT NULL,
    "purchase_requisition_id" UUID,
    "po_no" VARCHAR(50) NOT NULL,
    "po_date" DATE NOT NULL,
    "currency" CHAR(3) NOT NULL,
    "delivery_date" DATE,
    "status" "po_status_enum" NOT NULL DEFAULT 'draft',

    CONSTRAINT "purchase_orders_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "purchase_order_items" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "purchase_order_id" UUID NOT NULL,
    "material_type" "material_type_enum" NOT NULL,
    "fabric_id" UUID,
    "trim_id" UUID,
    "quantity" DECIMAL(14,3) NOT NULL,
    "unit_price" DECIMAL(14,4) NOT NULL,
    "uom_id" UUID NOT NULL,
    "quantity_received" DECIMAL(14,3) NOT NULL DEFAULT 0,

    CONSTRAINT "purchase_order_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "goods_receipt_notes" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "purchase_order_id" UUID NOT NULL,
    "grn_no" VARCHAR(50) NOT NULL,
    "received_date" DATE NOT NULL,
    "warehouse_id" UUID NOT NULL,
    "received_by" UUID,

    CONSTRAINT "goods_receipt_notes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "grn_items" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "goods_receipt_note_id" UUID NOT NULL,
    "purchase_order_item_id" UUID NOT NULL,
    "quantity_received" DECIMAL(14,3) NOT NULL,
    "quantity_accepted" DECIMAL(14,3) NOT NULL,
    "quantity_rejected" DECIMAL(14,3) NOT NULL DEFAULT 0,
    "lot_no" VARCHAR(50) NOT NULL,
    "dye_lot" VARCHAR(50),

    CONSTRAINT "grn_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "supplier_invoices" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "supplier_id" UUID NOT NULL,
    "purchase_order_id" UUID NOT NULL,
    "invoice_no" VARCHAR(50) NOT NULL,
    "invoice_date" DATE NOT NULL,
    "amount" DECIMAL(14,2) NOT NULL,
    "currency" CHAR(3) NOT NULL,
    "match_status" "match_status_enum" NOT NULL DEFAULT 'pending',

    CONSTRAINT "supplier_invoices_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "supplier_invoice_items" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "supplier_invoice_id" UUID NOT NULL,
    "purchase_order_item_id" UUID NOT NULL,
    "quantity" DECIMAL(14,3) NOT NULL,
    "unit_price" DECIMAL(14,4) NOT NULL,
    "amount" DECIMAL(14,2) NOT NULL,

    CONSTRAINT "supplier_invoice_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "import_lc_references" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "purchase_order_id" UUID NOT NULL,
    "lc_number" VARCHAR(50) NOT NULL,
    "lc_bank" VARCHAR(150),
    "issuing_date" DATE,
    "shipment_eta" DATE,
    "status" VARCHAR(30) NOT NULL DEFAULT 'open',

    CONSTRAINT "import_lc_references_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "shipments" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "factory_id" UUID NOT NULL,
    "order_id" UUID NOT NULL,
    "shipment_no" VARCHAR(50) NOT NULL,
    "booking_date" DATE NOT NULL,
    "vessel_flight" VARCHAR(100),
    "ex_factory_date" DATE,
    "status" "shipment_status_enum" NOT NULL DEFAULT 'booked',

    CONSTRAINT "shipments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "shipment_cartons" (
    "shipment_id" UUID NOT NULL,
    "carton_id" UUID NOT NULL,

    CONSTRAINT "shipment_cartons_pkey" PRIMARY KEY ("shipment_id","carton_id")
);

-- CreateTable
CREATE TABLE "commercial_invoices" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "shipment_id" UUID NOT NULL,
    "buyer_id" UUID NOT NULL,
    "invoice_no" VARCHAR(50) NOT NULL,
    "invoice_date" DATE NOT NULL,
    "currency" CHAR(3) NOT NULL,
    "total_amount" DECIMAL(14,2) NOT NULL,

    CONSTRAINT "commercial_invoices_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "commercial_invoice_items" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "commercial_invoice_id" UUID NOT NULL,
    "order_line_id" UUID NOT NULL,
    "quantity" INTEGER NOT NULL,
    "unit_price" DECIMAL(14,2) NOT NULL,
    "amount" DECIMAL(14,2) NOT NULL,

    CONSTRAINT "commercial_invoice_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "shipment_packing_lists" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "shipment_id" UUID NOT NULL,
    "format_template_id" UUID,
    "generated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "pdf_attachment_id" UUID,

    CONSTRAINT "shipment_packing_lists_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "currencies" (
    "code" CHAR(3) NOT NULL,
    "name" VARCHAR(50) NOT NULL,
    "symbol" VARCHAR(5),

    CONSTRAINT "currencies_pkey" PRIMARY KEY ("code")
);

-- CreateTable
CREATE TABLE "exchange_rates" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "from_currency" CHAR(3) NOT NULL,
    "to_currency" CHAR(3) NOT NULL,
    "rate" DECIMAL(18,8) NOT NULL,
    "effective_date" DATE NOT NULL,
    "source" VARCHAR(50),

    CONSTRAINT "exchange_rates_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "chart_of_accounts" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "company_id" UUID NOT NULL,
    "account_code" VARCHAR(20) NOT NULL,
    "account_name" VARCHAR(150) NOT NULL,
    "account_type" "account_type_enum" NOT NULL,
    "parent_account_id" UUID,
    "is_active" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "chart_of_accounts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "journals" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "company_id" UUID NOT NULL,
    "journal_no" VARCHAR(50) NOT NULL,
    "journal_date" DATE NOT NULL,
    "source_type" "journal_source_enum" NOT NULL,
    "source_id" UUID,
    "status" "journal_status_enum" NOT NULL DEFAULT 'draft',
    "created_by" UUID,
    "approved_by" UUID,

    CONSTRAINT "journals_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "journal_lines" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "journal_id" UUID NOT NULL,
    "account_id" UUID NOT NULL,
    "debit_amount" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "credit_amount" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "currency" CHAR(3) NOT NULL,
    "exchange_rate" DECIMAL(18,8) NOT NULL DEFAULT 1,
    "description" TEXT,

    CONSTRAINT "journal_lines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "accounts_payable" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "supplier_id" UUID NOT NULL,
    "supplier_invoice_id" UUID NOT NULL,
    "amount_due" DECIMAL(14,2) NOT NULL,
    "amount_paid" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "due_date" DATE NOT NULL,
    "status" "ap_ar_status_enum" NOT NULL DEFAULT 'open',

    CONSTRAINT "accounts_payable_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "accounts_receivable" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "buyer_id" UUID NOT NULL,
    "commercial_invoice_id" UUID NOT NULL,
    "amount_due" DECIMAL(14,2) NOT NULL,
    "amount_paid" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "due_date" DATE NOT NULL,
    "status" "ap_ar_status_enum" NOT NULL DEFAULT 'open',

    CONSTRAINT "accounts_receivable_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payments" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "payment_type" "payment_type_enum" NOT NULL,
    "party_type" "party_type_enum" NOT NULL,
    "party_id" UUID NOT NULL,
    "amount" DECIMAL(14,2) NOT NULL,
    "currency" CHAR(3) NOT NULL,
    "payment_date" DATE NOT NULL,
    "payment_method" VARCHAR(50),
    "reference_no" VARCHAR(100),

    CONSTRAINT "payments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payment_allocations" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "payment_id" UUID NOT NULL,
    "accounts_payable_id" UUID,
    "accounts_receivable_id" UUID,
    "allocated_amount" DECIMAL(14,2) NOT NULL,

    CONSTRAINT "payment_allocations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "order_costings" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "order_id" UUID NOT NULL,
    "estimated_material_cost" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "actual_material_cost" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "estimated_labor_cost" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "actual_labor_cost" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "overhead_allocated" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "total_actual_cost" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "margin_actual_pct" DECIMAL(6,3),
    "calculated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "order_costings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "employees" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "company_id" UUID NOT NULL,
    "factory_id" UUID NOT NULL,
    "department_id" UUID NOT NULL,
    "user_id" UUID,
    "employee_code" VARCHAR(30) NOT NULL,
    "full_name" VARCHAR(150) NOT NULL,
    "designation" VARCHAR(100),
    "wage_type" "wage_type_enum" NOT NULL,
    "date_of_joining" DATE NOT NULL,
    "statutory_id" VARCHAR(50),
    "status" "user_status_enum" NOT NULL DEFAULT 'active',

    CONSTRAINT "employees_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "attendance" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "employee_id" UUID NOT NULL,
    "attendance_date" DATE NOT NULL,
    "check_in" TIMESTAMPTZ(6),
    "check_out" TIMESTAMPTZ(6),
    "source" "attendance_source_enum" NOT NULL DEFAULT 'manual',
    "overtime_minutes" INTEGER NOT NULL DEFAULT 0,
    "status" "attendance_status_enum" NOT NULL DEFAULT 'present',

    CONSTRAINT "attendance_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "leave_types" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "name" VARCHAR(50) NOT NULL,
    "max_days_per_year" SMALLINT,
    "is_paid" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "leave_types_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "leave_applications" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "employee_id" UUID NOT NULL,
    "leave_type_id" UUID NOT NULL,
    "start_date" DATE NOT NULL,
    "end_date" DATE NOT NULL,
    "days_count" DECIMAL(5,1) NOT NULL,
    "reason" TEXT,
    "status" "leave_status_enum" NOT NULL DEFAULT 'pending',
    "approved_by" UUID,

    CONSTRAINT "leave_applications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "leave_balances" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "employee_id" UUID NOT NULL,
    "leave_type_id" UUID NOT NULL,
    "year" SMALLINT NOT NULL,
    "entitled_days" DECIMAL(5,1) NOT NULL,
    "used_days" DECIMAL(5,1) NOT NULL DEFAULT 0,
    "balance_days" DECIMAL(5,1) NOT NULL,

    CONSTRAINT "leave_balances_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "salary_structures" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "employee_id" UUID NOT NULL,
    "effective_date" DATE NOT NULL,
    "basic_salary" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "allowances" JSONB,
    "wage_type" "wage_type_enum" NOT NULL,

    CONSTRAINT "salary_structures_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payroll_runs" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "factory_id" UUID NOT NULL,
    "pay_period_start" DATE NOT NULL,
    "pay_period_end" DATE NOT NULL,
    "status" "payroll_status_enum" NOT NULL DEFAULT 'draft',
    "run_date" DATE NOT NULL,
    "approved_by" UUID,

    CONSTRAINT "payroll_runs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payslips" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "payroll_run_id" UUID NOT NULL,
    "employee_id" UUID NOT NULL,
    "base_wage" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "overtime_amount" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "incentive_amount" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "gross_pay" DECIMAL(14,2) NOT NULL,
    "deductions_amount" DECIMAL(14,2) NOT NULL DEFAULT 0,
    "net_pay" DECIMAL(14,2) NOT NULL,
    "generated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "payslips_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payslip_lines" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "payslip_id" UUID NOT NULL,
    "component_type" "component_type_enum" NOT NULL,
    "component_name" VARCHAR(100) NOT NULL,
    "amount" DECIMAL(14,2) NOT NULL,

    CONSTRAINT "payslip_lines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "compliance_schemes" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "name" VARCHAR(100) NOT NULL,

    CONSTRAINT "compliance_schemes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "compliance_audits" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "factory_id" UUID NOT NULL,
    "compliance_scheme_id" UUID NOT NULL,
    "auditor_name" VARCHAR(150),
    "audit_date" DATE NOT NULL,
    "score" DECIMAL(6,2),
    "grade" VARCHAR(20),
    "findings_summary" TEXT,
    "status" VARCHAR(20) NOT NULL DEFAULT 'completed',

    CONSTRAINT "compliance_audits_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "corrective_action_plans" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "compliance_audit_id" UUID NOT NULL,
    "finding_description" TEXT NOT NULL,
    "owner_employee_id" UUID NOT NULL,
    "due_date" DATE NOT NULL,
    "status" "cap_status_enum" NOT NULL DEFAULT 'open',
    "closure_evidence_attachment_id" UUID,

    CONSTRAINT "corrective_action_plans_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "certificates" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "factory_id" UUID NOT NULL,
    "certificate_type" VARCHAR(50) NOT NULL,
    "issuing_body" VARCHAR(150),
    "scope" TEXT,
    "valid_from" DATE NOT NULL,
    "valid_to" DATE NOT NULL,
    "attachment_id" UUID,

    CONSTRAINT "certificates_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "compliance_documents" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "related_entity_type" VARCHAR(30) NOT NULL,
    "related_entity_id" UUID NOT NULL,
    "attachment_id" UUID NOT NULL,

    CONSTRAINT "compliance_documents_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "attachments" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "entity_type" VARCHAR(50) NOT NULL,
    "entity_id" UUID NOT NULL,
    "file_name" VARCHAR(255) NOT NULL,
    "storage_key" TEXT NOT NULL,
    "mime_type" VARCHAR(100) NOT NULL,
    "size_bytes" BIGINT NOT NULL,
    "uploaded_by" UUID NOT NULL,
    "uploaded_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "virus_scan_status" VARCHAR(20) NOT NULL DEFAULT 'pending',

    CONSTRAINT "attachments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notifications" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "notification_type" VARCHAR(50) NOT NULL,
    "title" VARCHAR(200) NOT NULL,
    "body" TEXT,
    "related_entity_type" VARCHAR(50),
    "related_entity_id" UUID,
    "is_read" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "notifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "rag_documents" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "source_type" VARCHAR(50) NOT NULL,
    "source_attachment_id" UUID,
    "content_chunk" TEXT NOT NULL,
    "embedding" vector NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "rag_documents_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ai_tool_call_logs" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "tenant_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "tool_name" VARCHAR(100) NOT NULL,
    "arguments" JSONB NOT NULL,
    "result_summary" JSONB,
    "called_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ai_tool_call_logs_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "tenants_slug_key" ON "tenants"("slug");

-- CreateIndex
CREATE UNIQUE INDEX "companies_tenant_id_name_key" ON "companies"("tenant_id", "name");

-- CreateIndex
CREATE UNIQUE INDEX "factories_company_id_code_key" ON "factories"("company_id", "code");

-- CreateIndex
CREATE UNIQUE INDEX "departments_factory_id_name_key" ON "departments"("factory_id", "name");

-- CreateIndex
CREATE UNIQUE INDEX "users_tenant_id_email_key" ON "users"("tenant_id", "email");

-- CreateIndex
CREATE UNIQUE INDEX "roles_tenant_id_name_key" ON "roles"("tenant_id", "name");

-- CreateIndex
CREATE UNIQUE INDEX "permissions_code_key" ON "permissions"("code");

-- CreateIndex
CREATE UNIQUE INDEX "user_factory_access_user_id_factory_id_key" ON "user_factory_access"("user_id", "factory_id");

-- CreateIndex
CREATE UNIQUE INDEX "refresh_tokens_token_hash_key" ON "refresh_tokens"("token_hash");

-- CreateIndex
CREATE UNIQUE INDEX "buyers_tenant_id_code_key" ON "buyers"("tenant_id", "code");

-- CreateIndex
CREATE UNIQUE INDEX "styles_tenant_id_buyer_id_style_code_key" ON "styles"("tenant_id", "buyer_id", "style_code");

-- CreateIndex
CREATE UNIQUE INDEX "style_sizes_style_id_size_name_key" ON "style_sizes"("style_id", "size_name");

-- CreateIndex
CREATE UNIQUE INDEX "style_colors_style_id_color_name_key" ON "style_colors"("style_id", "color_name");

-- CreateIndex
CREATE UNIQUE INDEX "tech_packs_style_id_version_key" ON "tech_packs"("style_id", "version");

-- CreateIndex
CREATE UNIQUE INDEX "boms_style_id_version_key" ON "boms"("style_id", "version");

-- CreateIndex
CREATE UNIQUE INDEX "costing_sheets_style_id_version_key" ON "costing_sheets"("style_id", "version");

-- CreateIndex
CREATE UNIQUE INDEX "samples_style_id_sample_type_iteration_no_key" ON "samples"("style_id", "sample_type", "iteration_no");

-- CreateIndex
CREATE UNIQUE INDEX "sales_orders_tenant_id_order_no_key" ON "sales_orders"("tenant_id", "order_no");

-- CreateIndex
CREATE UNIQUE INDEX "order_lines_order_id_style_color_id_style_size_id_key" ON "order_lines"("order_id", "style_color_id", "style_size_id");

-- CreateIndex
CREATE UNIQUE INDEX "order_factory_splits_order_id_factory_id_key" ON "order_factory_splits"("order_id", "factory_id");

-- CreateIndex
CREATE UNIQUE INDEX "tna_calendars_order_id_key" ON "tna_calendars"("order_id");

-- CreateIndex
CREATE UNIQUE INDEX "units_of_measure_tenant_id_code_key" ON "units_of_measure"("tenant_id", "code");

-- CreateIndex
CREATE UNIQUE INDEX "uom_conversions_from_uom_id_to_uom_id_key" ON "uom_conversions"("from_uom_id", "to_uom_id");

-- CreateIndex
CREATE UNIQUE INDEX "fabrics_tenant_id_fabric_code_key" ON "fabrics"("tenant_id", "fabric_code");

-- CreateIndex
CREATE UNIQUE INDEX "trims_tenant_id_trim_code_key" ON "trims"("tenant_id", "trim_code");

-- CreateIndex
CREATE UNIQUE INDEX "supplier_materials_supplier_id_material_type_fabric_id_trim_key" ON "supplier_materials"("supplier_id", "material_type", "fabric_id", "trim_id");

-- CreateIndex
CREATE UNIQUE INDEX "production_lines_factory_id_code_key" ON "production_lines"("factory_id", "code");

-- CreateIndex
CREATE UNIQUE INDEX "line_capacity_plans_production_line_id_plan_date_key" ON "line_capacity_plans"("production_line_id", "plan_date");

-- CreateIndex
CREATE UNIQUE INDEX "daily_production_plans_production_line_id_plan_date_order_i_key" ON "daily_production_plans"("production_line_id", "plan_date", "order_id", "department");

-- CreateIndex
CREATE UNIQUE INDEX "fabric_issues_tenant_id_issue_no_key" ON "fabric_issues"("tenant_id", "issue_no");

-- CreateIndex
CREATE UNIQUE INDEX "markers_style_id_marker_no_key" ON "markers"("style_id", "marker_no");

-- CreateIndex
CREATE UNIQUE INDEX "cutting_orders_tenant_id_cutting_order_no_key" ON "cutting_orders"("tenant_id", "cutting_order_no");

-- CreateIndex
CREATE UNIQUE INDEX "cut_bundles_cutting_order_id_bundle_no_key" ON "cut_bundles"("cutting_order_id", "bundle_no");

-- CreateIndex
CREATE UNIQUE INDEX "operation_bulletins_style_id_version_key" ON "operation_bulletins"("style_id", "version");

-- CreateIndex
CREATE UNIQUE INDEX "operation_bulletin_lines_operation_bulletin_id_operation_se_key" ON "operation_bulletin_lines"("operation_bulletin_id", "operation_seq");

-- CreateIndex
CREATE UNIQUE INDEX "bundle_scans_client_scan_uuid_key" ON "bundle_scans"("client_scan_uuid");

-- CreateIndex
CREATE UNIQUE INDEX "hourly_production_records_production_line_id_record_date_ho_key" ON "hourly_production_records"("production_line_id", "record_date", "hour_slot");

-- CreateIndex
CREATE UNIQUE INDEX "downtime_reasons_tenant_id_code_key" ON "downtime_reasons"("tenant_id", "code");

-- CreateIndex
CREATE UNIQUE INDEX "cartons_barcode_key" ON "cartons"("barcode");

-- CreateIndex
CREATE UNIQUE INDEX "cartons_order_id_carton_no_key" ON "cartons"("order_id", "carton_no");

-- CreateIndex
CREATE UNIQUE INDEX "defect_codes_tenant_id_code_key" ON "defect_codes"("tenant_id", "code");

-- CreateIndex
CREATE UNIQUE INDEX "endline_inspections_production_line_id_order_id_inspection__key" ON "endline_inspections"("production_line_id", "order_id", "inspection_date");

-- CreateIndex
CREATE UNIQUE INDEX "warehouses_factory_id_code_key" ON "warehouses"("factory_id", "code");

-- CreateIndex
CREATE UNIQUE INDEX "stock_items_tenant_id_sku_code_key" ON "stock_items"("tenant_id", "sku_code");

-- CreateIndex
CREATE UNIQUE INDEX "stock_lots_stock_item_id_warehouse_id_lot_no_key" ON "stock_lots"("stock_item_id", "warehouse_id", "lot_no");

-- CreateIndex
CREATE INDEX "stock_movements_source_document_type_source_document_id_idx" ON "stock_movements"("source_document_type", "source_document_id");

-- CreateIndex
CREATE UNIQUE INDEX "suppliers_tenant_id_code_key" ON "suppliers"("tenant_id", "code");

-- CreateIndex
CREATE UNIQUE INDEX "purchase_requisitions_tenant_id_requisition_no_key" ON "purchase_requisitions"("tenant_id", "requisition_no");

-- CreateIndex
CREATE UNIQUE INDEX "purchase_orders_tenant_id_po_no_key" ON "purchase_orders"("tenant_id", "po_no");

-- CreateIndex
CREATE UNIQUE INDEX "goods_receipt_notes_tenant_id_grn_no_key" ON "goods_receipt_notes"("tenant_id", "grn_no");

-- CreateIndex
CREATE UNIQUE INDEX "supplier_invoices_supplier_id_invoice_no_key" ON "supplier_invoices"("supplier_id", "invoice_no");

-- CreateIndex
CREATE UNIQUE INDEX "import_lc_references_purchase_order_id_key" ON "import_lc_references"("purchase_order_id");

-- CreateIndex
CREATE UNIQUE INDEX "shipments_tenant_id_shipment_no_key" ON "shipments"("tenant_id", "shipment_no");

-- CreateIndex
CREATE UNIQUE INDEX "shipment_cartons_carton_id_key" ON "shipment_cartons"("carton_id");

-- CreateIndex
CREATE UNIQUE INDEX "commercial_invoices_tenant_id_invoice_no_key" ON "commercial_invoices"("tenant_id", "invoice_no");

-- CreateIndex
CREATE UNIQUE INDEX "shipment_packing_lists_shipment_id_key" ON "shipment_packing_lists"("shipment_id");

-- CreateIndex
CREATE UNIQUE INDEX "exchange_rates_tenant_id_from_currency_to_currency_effectiv_key" ON "exchange_rates"("tenant_id", "from_currency", "to_currency", "effective_date");

-- CreateIndex
CREATE UNIQUE INDEX "chart_of_accounts_company_id_account_code_key" ON "chart_of_accounts"("company_id", "account_code");

-- CreateIndex
CREATE UNIQUE INDEX "journals_company_id_journal_no_key" ON "journals"("company_id", "journal_no");

-- CreateIndex
CREATE UNIQUE INDEX "order_costings_order_id_key" ON "order_costings"("order_id");

-- CreateIndex
CREATE UNIQUE INDEX "employees_tenant_id_employee_code_key" ON "employees"("tenant_id", "employee_code");

-- CreateIndex
CREATE UNIQUE INDEX "attendance_employee_id_attendance_date_key" ON "attendance"("employee_id", "attendance_date");

-- CreateIndex
CREATE UNIQUE INDEX "leave_types_tenant_id_name_key" ON "leave_types"("tenant_id", "name");

-- CreateIndex
CREATE UNIQUE INDEX "leave_balances_employee_id_leave_type_id_year_key" ON "leave_balances"("employee_id", "leave_type_id", "year");

-- CreateIndex
CREATE UNIQUE INDEX "salary_structures_employee_id_effective_date_key" ON "salary_structures"("employee_id", "effective_date");

-- CreateIndex
CREATE UNIQUE INDEX "payroll_runs_factory_id_pay_period_start_pay_period_end_key" ON "payroll_runs"("factory_id", "pay_period_start", "pay_period_end");

-- CreateIndex
CREATE UNIQUE INDEX "payslips_payroll_run_id_employee_id_key" ON "payslips"("payroll_run_id", "employee_id");

-- CreateIndex
CREATE UNIQUE INDEX "compliance_schemes_tenant_id_name_key" ON "compliance_schemes"("tenant_id", "name");

-- CreateIndex
CREATE INDEX "attachments_entity_type_entity_id_idx" ON "attachments"("entity_type", "entity_id");

-- AddForeignKey
ALTER TABLE "companies" ADD CONSTRAINT "companies_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "factories" ADD CONSTRAINT "factories_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "companies"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "factories" ADD CONSTRAINT "factories_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "branches" ADD CONSTRAINT "branches_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "branches" ADD CONSTRAINT "branches_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "companies"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "branches" ADD CONSTRAINT "branches_factory_id_fkey" FOREIGN KEY ("factory_id") REFERENCES "factories"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "departments" ADD CONSTRAINT "departments_factory_id_fkey" FOREIGN KEY ("factory_id") REFERENCES "factories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "departments" ADD CONSTRAINT "departments_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "departments" ADD CONSTRAINT "departments_parent_department_id_fkey" FOREIGN KEY ("parent_department_id") REFERENCES "departments"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "users" ADD CONSTRAINT "users_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "mfa_factors" ADD CONSTRAINT "mfa_factors_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "roles" ADD CONSTRAINT "roles_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "role_permissions" ADD CONSTRAINT "role_permissions_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "roles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "role_permissions" ADD CONSTRAINT "role_permissions_permission_id_fkey" FOREIGN KEY ("permission_id") REFERENCES "permissions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_roles" ADD CONSTRAINT "user_roles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_roles" ADD CONSTRAINT "user_roles_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "roles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_roles" ADD CONSTRAINT "user_roles_factory_id_fkey" FOREIGN KEY ("factory_id") REFERENCES "factories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_factory_access" ADD CONSTRAINT "user_factory_access_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_factory_access" ADD CONSTRAINT "user_factory_access_factory_id_fkey" FOREIGN KEY ("factory_id") REFERENCES "factories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "refresh_tokens" ADD CONSTRAINT "refresh_tokens_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "sessions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "refresh_tokens" ADD CONSTRAINT "refresh_tokens_replaced_by_token_id_fkey" FOREIGN KEY ("replaced_by_token_id") REFERENCES "refresh_tokens"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "buyers" ADD CONSTRAINT "buyers_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "buyers" ADD CONSTRAINT "buyers_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "companies"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "buyers" ADD CONSTRAINT "buyers_default_aql_sampling_plan_id_fkey" FOREIGN KEY ("default_aql_sampling_plan_id") REFERENCES "aql_sampling_plans"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "buyer_contacts" ADD CONSTRAINT "buyer_contacts_buyer_id_fkey" FOREIGN KEY ("buyer_id") REFERENCES "buyers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "styles" ADD CONSTRAINT "styles_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "styles" ADD CONSTRAINT "styles_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "companies"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "styles" ADD CONSTRAINT "styles_buyer_id_fkey" FOREIGN KEY ("buyer_id") REFERENCES "buyers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "style_sizes" ADD CONSTRAINT "style_sizes_style_id_fkey" FOREIGN KEY ("style_id") REFERENCES "styles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "style_colors" ADD CONSTRAINT "style_colors_style_id_fkey" FOREIGN KEY ("style_id") REFERENCES "styles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tech_packs" ADD CONSTRAINT "tech_packs_style_id_fkey" FOREIGN KEY ("style_id") REFERENCES "styles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tech_packs" ADD CONSTRAINT "tech_packs_attachment_id_fkey" FOREIGN KEY ("attachment_id") REFERENCES "attachments"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tech_packs" ADD CONSTRAINT "tech_packs_approved_by_fkey" FOREIGN KEY ("approved_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "boms" ADD CONSTRAINT "boms_style_id_fkey" FOREIGN KEY ("style_id") REFERENCES "styles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bom_items" ADD CONSTRAINT "bom_items_bom_id_fkey" FOREIGN KEY ("bom_id") REFERENCES "boms"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bom_items" ADD CONSTRAINT "bom_items_fabric_id_fkey" FOREIGN KEY ("fabric_id") REFERENCES "fabrics"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bom_items" ADD CONSTRAINT "bom_items_trim_id_fkey" FOREIGN KEY ("trim_id") REFERENCES "trims"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bom_items" ADD CONSTRAINT "bom_items_style_size_id_fkey" FOREIGN KEY ("style_size_id") REFERENCES "style_sizes"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bom_items" ADD CONSTRAINT "bom_items_uom_id_fkey" FOREIGN KEY ("uom_id") REFERENCES "units_of_measure"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "costing_sheets" ADD CONSTRAINT "costing_sheets_style_id_fkey" FOREIGN KEY ("style_id") REFERENCES "styles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "samples" ADD CONSTRAINT "samples_style_id_fkey" FOREIGN KEY ("style_id") REFERENCES "styles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sales_orders" ADD CONSTRAINT "sales_orders_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sales_orders" ADD CONSTRAINT "sales_orders_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "companies"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sales_orders" ADD CONSTRAINT "sales_orders_factory_id_fkey" FOREIGN KEY ("factory_id") REFERENCES "factories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sales_orders" ADD CONSTRAINT "sales_orders_buyer_id_fkey" FOREIGN KEY ("buyer_id") REFERENCES "buyers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sales_orders" ADD CONSTRAINT "sales_orders_style_id_fkey" FOREIGN KEY ("style_id") REFERENCES "styles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_lines" ADD CONSTRAINT "order_lines_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "sales_orders"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_lines" ADD CONSTRAINT "order_lines_style_color_id_fkey" FOREIGN KEY ("style_color_id") REFERENCES "style_colors"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_lines" ADD CONSTRAINT "order_lines_style_size_id_fkey" FOREIGN KEY ("style_size_id") REFERENCES "style_sizes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_amendments" ADD CONSTRAINT "order_amendments_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "sales_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_amendments" ADD CONSTRAINT "order_amendments_amended_by_fkey" FOREIGN KEY ("amended_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_factory_splits" ADD CONSTRAINT "order_factory_splits_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "sales_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_factory_splits" ADD CONSTRAINT "order_factory_splits_factory_id_fkey" FOREIGN KEY ("factory_id") REFERENCES "factories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tna_templates" ADD CONSTRAINT "tna_templates_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tna_template_milestones" ADD CONSTRAINT "tna_template_milestones_tna_template_id_fkey" FOREIGN KEY ("tna_template_id") REFERENCES "tna_templates"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tna_calendars" ADD CONSTRAINT "tna_calendars_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "sales_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tna_calendars" ADD CONSTRAINT "tna_calendars_tna_template_id_fkey" FOREIGN KEY ("tna_template_id") REFERENCES "tna_templates"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tna_milestones" ADD CONSTRAINT "tna_milestones_tna_calendar_id_fkey" FOREIGN KEY ("tna_calendar_id") REFERENCES "tna_calendars"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tna_milestones" ADD CONSTRAINT "tna_milestones_responsible_user_id_fkey" FOREIGN KEY ("responsible_user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "units_of_measure" ADD CONSTRAINT "units_of_measure_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "uom_conversions" ADD CONSTRAINT "uom_conversions_from_uom_id_fkey" FOREIGN KEY ("from_uom_id") REFERENCES "units_of_measure"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "uom_conversions" ADD CONSTRAINT "uom_conversions_to_uom_id_fkey" FOREIGN KEY ("to_uom_id") REFERENCES "units_of_measure"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fabrics" ADD CONSTRAINT "fabrics_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fabrics" ADD CONSTRAINT "fabrics_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "companies"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fabrics" ADD CONSTRAINT "fabrics_default_supplier_id_fkey" FOREIGN KEY ("default_supplier_id") REFERENCES "suppliers"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fabrics" ADD CONSTRAINT "fabrics_uom_id_fkey" FOREIGN KEY ("uom_id") REFERENCES "units_of_measure"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "trims" ADD CONSTRAINT "trims_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "trims" ADD CONSTRAINT "trims_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "companies"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "trims" ADD CONSTRAINT "trims_default_supplier_id_fkey" FOREIGN KEY ("default_supplier_id") REFERENCES "suppliers"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "trims" ADD CONSTRAINT "trims_uom_id_fkey" FOREIGN KEY ("uom_id") REFERENCES "units_of_measure"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "supplier_materials" ADD CONSTRAINT "supplier_materials_supplier_id_fkey" FOREIGN KEY ("supplier_id") REFERENCES "suppliers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "supplier_materials" ADD CONSTRAINT "supplier_materials_fabric_id_fkey" FOREIGN KEY ("fabric_id") REFERENCES "fabrics"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "supplier_materials" ADD CONSTRAINT "supplier_materials_trim_id_fkey" FOREIGN KEY ("trim_id") REFERENCES "trims"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "production_lines" ADD CONSTRAINT "production_lines_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "production_lines" ADD CONSTRAINT "production_lines_factory_id_fkey" FOREIGN KEY ("factory_id") REFERENCES "factories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "line_capacity_plans" ADD CONSTRAINT "line_capacity_plans_production_line_id_fkey" FOREIGN KEY ("production_line_id") REFERENCES "production_lines"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "line_bookings" ADD CONSTRAINT "line_bookings_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "sales_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "line_bookings" ADD CONSTRAINT "line_bookings_production_line_id_fkey" FOREIGN KEY ("production_line_id") REFERENCES "production_lines"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "daily_production_plans" ADD CONSTRAINT "daily_production_plans_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "daily_production_plans" ADD CONSTRAINT "daily_production_plans_factory_id_fkey" FOREIGN KEY ("factory_id") REFERENCES "factories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "daily_production_plans" ADD CONSTRAINT "daily_production_plans_production_line_id_fkey" FOREIGN KEY ("production_line_id") REFERENCES "production_lines"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "daily_production_plans" ADD CONSTRAINT "daily_production_plans_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "sales_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "mrp_requirements" ADD CONSTRAINT "mrp_requirements_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "sales_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "mrp_requirements" ADD CONSTRAINT "mrp_requirements_fabric_id_fkey" FOREIGN KEY ("fabric_id") REFERENCES "fabrics"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "mrp_requirements" ADD CONSTRAINT "mrp_requirements_trim_id_fkey" FOREIGN KEY ("trim_id") REFERENCES "trims"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fabric_issues" ADD CONSTRAINT "fabric_issues_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fabric_issues" ADD CONSTRAINT "fabric_issues_factory_id_fkey" FOREIGN KEY ("factory_id") REFERENCES "factories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fabric_issues" ADD CONSTRAINT "fabric_issues_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "sales_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fabric_issues" ADD CONSTRAINT "fabric_issues_warehouse_id_fkey" FOREIGN KEY ("warehouse_id") REFERENCES "warehouses"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fabric_issues" ADD CONSTRAINT "fabric_issues_issued_by_fkey" FOREIGN KEY ("issued_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fabric_issue_items" ADD CONSTRAINT "fabric_issue_items_fabric_issue_id_fkey" FOREIGN KEY ("fabric_issue_id") REFERENCES "fabric_issues"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fabric_issue_items" ADD CONSTRAINT "fabric_issue_items_fabric_id_fkey" FOREIGN KEY ("fabric_id") REFERENCES "fabrics"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fabric_issue_items" ADD CONSTRAINT "fabric_issue_items_stock_lot_id_fkey" FOREIGN KEY ("stock_lot_id") REFERENCES "stock_lots"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fabric_issue_items" ADD CONSTRAINT "fabric_issue_items_uom_id_fkey" FOREIGN KEY ("uom_id") REFERENCES "units_of_measure"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "markers" ADD CONSTRAINT "markers_style_id_fkey" FOREIGN KEY ("style_id") REFERENCES "styles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "markers" ADD CONSTRAINT "markers_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "lays" ADD CONSTRAINT "lays_marker_id_fkey" FOREIGN KEY ("marker_id") REFERENCES "markers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "lays" ADD CONSTRAINT "lays_cutting_order_id_fkey" FOREIGN KEY ("cutting_order_id") REFERENCES "cutting_orders"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cutting_orders" ADD CONSTRAINT "cutting_orders_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cutting_orders" ADD CONSTRAINT "cutting_orders_factory_id_fkey" FOREIGN KEY ("factory_id") REFERENCES "factories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cutting_orders" ADD CONSTRAINT "cutting_orders_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "sales_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cutting_orders" ADD CONSTRAINT "cutting_orders_marker_id_fkey" FOREIGN KEY ("marker_id") REFERENCES "markers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cut_bundles" ADD CONSTRAINT "cut_bundles_cutting_order_id_fkey" FOREIGN KEY ("cutting_order_id") REFERENCES "cutting_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cut_bundles" ADD CONSTRAINT "cut_bundles_style_color_id_fkey" FOREIGN KEY ("style_color_id") REFERENCES "style_colors"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cut_bundles" ADD CONSTRAINT "cut_bundles_style_size_id_fkey" FOREIGN KEY ("style_size_id") REFERENCES "style_sizes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fabric_relaxation_checks" ADD CONSTRAINT "fabric_relaxation_checks_lay_id_fkey" FOREIGN KEY ("lay_id") REFERENCES "lays"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "fabric_relaxation_checks" ADD CONSTRAINT "fabric_relaxation_checks_checked_by_fkey" FOREIGN KEY ("checked_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "operation_bulletins" ADD CONSTRAINT "operation_bulletins_style_id_fkey" FOREIGN KEY ("style_id") REFERENCES "styles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "operation_bulletin_lines" ADD CONSTRAINT "operation_bulletin_lines_operation_bulletin_id_fkey" FOREIGN KEY ("operation_bulletin_id") REFERENCES "operation_bulletins"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "line_balance_plans" ADD CONSTRAINT "line_balance_plans_operation_bulletin_id_fkey" FOREIGN KEY ("operation_bulletin_id") REFERENCES "operation_bulletins"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "line_balance_plans" ADD CONSTRAINT "line_balance_plans_production_line_id_fkey" FOREIGN KEY ("production_line_id") REFERENCES "production_lines"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "line_balance_plans" ADD CONSTRAINT "line_balance_plans_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "sales_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "line_balance_assignments" ADD CONSTRAINT "line_balance_assignments_line_balance_plan_id_fkey" FOREIGN KEY ("line_balance_plan_id") REFERENCES "line_balance_plans"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "line_balance_assignments" ADD CONSTRAINT "line_balance_assignments_operation_bulletin_line_id_fkey" FOREIGN KEY ("operation_bulletin_line_id") REFERENCES "operation_bulletin_lines"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "line_balance_assignments" ADD CONSTRAINT "line_balance_assignments_operator_employee_id_fkey" FOREIGN KEY ("operator_employee_id") REFERENCES "employees"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bundle_scans" ADD CONSTRAINT "bundle_scans_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bundle_scans" ADD CONSTRAINT "bundle_scans_cut_bundle_id_fkey" FOREIGN KEY ("cut_bundle_id") REFERENCES "cut_bundles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bundle_scans" ADD CONSTRAINT "bundle_scans_operation_bulletin_line_id_fkey" FOREIGN KEY ("operation_bulletin_line_id") REFERENCES "operation_bulletin_lines"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bundle_scans" ADD CONSTRAINT "bundle_scans_production_line_id_fkey" FOREIGN KEY ("production_line_id") REFERENCES "production_lines"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bundle_scans" ADD CONSTRAINT "bundle_scans_operator_employee_id_fkey" FOREIGN KEY ("operator_employee_id") REFERENCES "employees"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "hourly_production_records" ADD CONSTRAINT "hourly_production_records_production_line_id_fkey" FOREIGN KEY ("production_line_id") REFERENCES "production_lines"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "hourly_production_records" ADD CONSTRAINT "hourly_production_records_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "sales_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "downtime_reasons" ADD CONSTRAINT "downtime_reasons_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "downtime_logs" ADD CONSTRAINT "downtime_logs_production_line_id_fkey" FOREIGN KEY ("production_line_id") REFERENCES "production_lines"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "downtime_logs" ADD CONSTRAINT "downtime_logs_downtime_reason_id_fkey" FOREIGN KEY ("downtime_reason_id") REFERENCES "downtime_reasons"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "piece_rate_outputs" ADD CONSTRAINT "piece_rate_outputs_operator_employee_id_fkey" FOREIGN KEY ("operator_employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "piece_rate_outputs" ADD CONSTRAINT "piece_rate_outputs_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "sales_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "piece_rate_outputs" ADD CONSTRAINT "piece_rate_outputs_operation_bulletin_line_id_fkey" FOREIGN KEY ("operation_bulletin_line_id") REFERENCES "operation_bulletin_lines"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "finishing_checklists" ADD CONSTRAINT "finishing_checklists_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "finishing_checklists" ADD CONSTRAINT "finishing_checklists_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "sales_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "finishing_checklists" ADD CONSTRAINT "finishing_checklists_cut_bundle_id_fkey" FOREIGN KEY ("cut_bundle_id") REFERENCES "cut_bundles"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "finishing_checklists" ADD CONSTRAINT "finishing_checklists_checked_by_fkey" FOREIGN KEY ("checked_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "wash_recipes" ADD CONSTRAINT "wash_recipes_style_id_fkey" FOREIGN KEY ("style_id") REFERENCES "styles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "wash_orders" ADD CONSTRAINT "wash_orders_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "sales_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "wash_orders" ADD CONSTRAINT "wash_orders_wash_recipe_id_fkey" FOREIGN KEY ("wash_recipe_id") REFERENCES "wash_recipes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "wash_orders" ADD CONSTRAINT "wash_orders_subcontractor_supplier_id_fkey" FOREIGN KEY ("subcontractor_supplier_id") REFERENCES "suppliers"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "packing_configs" ADD CONSTRAINT "packing_configs_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "sales_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cartons" ADD CONSTRAINT "cartons_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "sales_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cartons" ADD CONSTRAINT "cartons_packing_config_id_fkey" FOREIGN KEY ("packing_config_id") REFERENCES "packing_configs"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "carton_items" ADD CONSTRAINT "carton_items_carton_id_fkey" FOREIGN KEY ("carton_id") REFERENCES "cartons"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "carton_items" ADD CONSTRAINT "carton_items_style_color_id_fkey" FOREIGN KEY ("style_color_id") REFERENCES "style_colors"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "carton_items" ADD CONSTRAINT "carton_items_style_size_id_fkey" FOREIGN KEY ("style_size_id") REFERENCES "style_sizes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "defect_codes" ADD CONSTRAINT "defect_codes_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inline_inspections" ADD CONSTRAINT "inline_inspections_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inline_inspections" ADD CONSTRAINT "inline_inspections_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "sales_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inline_inspections" ADD CONSTRAINT "inline_inspections_production_line_id_fkey" FOREIGN KEY ("production_line_id") REFERENCES "production_lines"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inline_inspections" ADD CONSTRAINT "inline_inspections_operation_bulletin_line_id_fkey" FOREIGN KEY ("operation_bulletin_line_id") REFERENCES "operation_bulletin_lines"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inline_inspections" ADD CONSTRAINT "inline_inspections_cut_bundle_id_fkey" FOREIGN KEY ("cut_bundle_id") REFERENCES "cut_bundles"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inline_inspections" ADD CONSTRAINT "inline_inspections_inspected_by_fkey" FOREIGN KEY ("inspected_by") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inline_inspection_defects" ADD CONSTRAINT "inline_inspection_defects_inline_inspection_id_fkey" FOREIGN KEY ("inline_inspection_id") REFERENCES "inline_inspections"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inline_inspection_defects" ADD CONSTRAINT "inline_inspection_defects_defect_code_id_fkey" FOREIGN KEY ("defect_code_id") REFERENCES "defect_codes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "endline_inspections" ADD CONSTRAINT "endline_inspections_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "endline_inspections" ADD CONSTRAINT "endline_inspections_production_line_id_fkey" FOREIGN KEY ("production_line_id") REFERENCES "production_lines"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "endline_inspections" ADD CONSTRAINT "endline_inspections_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "sales_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "endline_inspections" ADD CONSTRAINT "endline_inspections_inspected_by_fkey" FOREIGN KEY ("inspected_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "endline_inspection_defects" ADD CONSTRAINT "endline_inspection_defects_endline_inspection_id_fkey" FOREIGN KEY ("endline_inspection_id") REFERENCES "endline_inspections"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "endline_inspection_defects" ADD CONSTRAINT "endline_inspection_defects_defect_code_id_fkey" FOREIGN KEY ("defect_code_id") REFERENCES "defect_codes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "aql_sampling_plans" ADD CONSTRAINT "aql_sampling_plans_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "aql_sampling_plan_rows" ADD CONSTRAINT "aql_sampling_plan_rows_aql_sampling_plan_id_fkey" FOREIGN KEY ("aql_sampling_plan_id") REFERENCES "aql_sampling_plans"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "aql_inspection_reports" ADD CONSTRAINT "aql_inspection_reports_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "aql_inspection_reports" ADD CONSTRAINT "aql_inspection_reports_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "sales_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "aql_inspection_reports" ADD CONSTRAINT "aql_inspection_reports_aql_sampling_plan_id_fkey" FOREIGN KEY ("aql_sampling_plan_id") REFERENCES "aql_sampling_plans"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "aql_inspection_reports" ADD CONSTRAINT "aql_inspection_reports_inspected_by_fkey" FOREIGN KEY ("inspected_by") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "aql_inspection_reports" ADD CONSTRAINT "aql_inspection_reports_report_attachment_id_fkey" FOREIGN KEY ("report_attachment_id") REFERENCES "attachments"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "aql_inspection_report_cartons" ADD CONSTRAINT "aql_inspection_report_cartons_aql_inspection_report_id_fkey" FOREIGN KEY ("aql_inspection_report_id") REFERENCES "aql_inspection_reports"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "aql_inspection_report_cartons" ADD CONSTRAINT "aql_inspection_report_cartons_carton_id_fkey" FOREIGN KEY ("carton_id") REFERENCES "cartons"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "rework_orders" ADD CONSTRAINT "rework_orders_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "rework_orders" ADD CONSTRAINT "rework_orders_source_inline_inspection_id_fkey" FOREIGN KEY ("source_inline_inspection_id") REFERENCES "inline_inspections"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "rework_orders" ADD CONSTRAINT "rework_orders_source_endline_inspection_id_fkey" FOREIGN KEY ("source_endline_inspection_id") REFERENCES "endline_inspections"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "rework_orders" ADD CONSTRAINT "rework_orders_source_aql_report_id_fkey" FOREIGN KEY ("source_aql_report_id") REFERENCES "aql_inspection_reports"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "rework_orders" ADD CONSTRAINT "rework_orders_defect_code_id_fkey" FOREIGN KEY ("defect_code_id") REFERENCES "defect_codes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "rework_orders" ADD CONSTRAINT "rework_orders_assigned_to_employee_id_fkey" FOREIGN KEY ("assigned_to_employee_id") REFERENCES "employees"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "warehouses" ADD CONSTRAINT "warehouses_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "warehouses" ADD CONSTRAINT "warehouses_factory_id_fkey" FOREIGN KEY ("factory_id") REFERENCES "factories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_items" ADD CONSTRAINT "stock_items_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_items" ADD CONSTRAINT "stock_items_fabric_id_fkey" FOREIGN KEY ("fabric_id") REFERENCES "fabrics"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_items" ADD CONSTRAINT "stock_items_trim_id_fkey" FOREIGN KEY ("trim_id") REFERENCES "trims"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_items" ADD CONSTRAINT "stock_items_style_id_fkey" FOREIGN KEY ("style_id") REFERENCES "styles"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_items" ADD CONSTRAINT "stock_items_style_color_id_fkey" FOREIGN KEY ("style_color_id") REFERENCES "style_colors"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_items" ADD CONSTRAINT "stock_items_style_size_id_fkey" FOREIGN KEY ("style_size_id") REFERENCES "style_sizes"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_items" ADD CONSTRAINT "stock_items_uom_id_fkey" FOREIGN KEY ("uom_id") REFERENCES "units_of_measure"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_lots" ADD CONSTRAINT "stock_lots_stock_item_id_fkey" FOREIGN KEY ("stock_item_id") REFERENCES "stock_items"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_lots" ADD CONSTRAINT "stock_lots_warehouse_id_fkey" FOREIGN KEY ("warehouse_id") REFERENCES "warehouses"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_movements" ADD CONSTRAINT "stock_movements_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_movements" ADD CONSTRAINT "stock_movements_stock_item_id_fkey" FOREIGN KEY ("stock_item_id") REFERENCES "stock_items"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_movements" ADD CONSTRAINT "stock_movements_warehouse_id_fkey" FOREIGN KEY ("warehouse_id") REFERENCES "warehouses"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_movements" ADD CONSTRAINT "stock_movements_stock_lot_id_fkey" FOREIGN KEY ("stock_lot_id") REFERENCES "stock_lots"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_transfers" ADD CONSTRAINT "stock_transfers_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_transfers" ADD CONSTRAINT "stock_transfers_from_warehouse_id_fkey" FOREIGN KEY ("from_warehouse_id") REFERENCES "warehouses"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_transfers" ADD CONSTRAINT "stock_transfers_to_warehouse_id_fkey" FOREIGN KEY ("to_warehouse_id") REFERENCES "warehouses"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_transfers" ADD CONSTRAINT "stock_transfers_stock_item_id_fkey" FOREIGN KEY ("stock_item_id") REFERENCES "stock_items"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_transfers" ADD CONSTRAINT "stock_transfers_stock_lot_id_fkey" FOREIGN KEY ("stock_lot_id") REFERENCES "stock_lots"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_adjustments" ADD CONSTRAINT "stock_adjustments_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_adjustments" ADD CONSTRAINT "stock_adjustments_stock_item_id_fkey" FOREIGN KEY ("stock_item_id") REFERENCES "stock_items"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_adjustments" ADD CONSTRAINT "stock_adjustments_warehouse_id_fkey" FOREIGN KEY ("warehouse_id") REFERENCES "warehouses"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_adjustments" ADD CONSTRAINT "stock_adjustments_stock_lot_id_fkey" FOREIGN KEY ("stock_lot_id") REFERENCES "stock_lots"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_adjustments" ADD CONSTRAINT "stock_adjustments_approved_by_fkey" FOREIGN KEY ("approved_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "suppliers" ADD CONSTRAINT "suppliers_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "suppliers" ADD CONSTRAINT "suppliers_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "companies"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_requisitions" ADD CONSTRAINT "purchase_requisitions_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_requisitions" ADD CONSTRAINT "purchase_requisitions_factory_id_fkey" FOREIGN KEY ("factory_id") REFERENCES "factories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_requisitions" ADD CONSTRAINT "purchase_requisitions_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "sales_orders"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_requisitions" ADD CONSTRAINT "purchase_requisitions_requested_by_fkey" FOREIGN KEY ("requested_by") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_requisitions" ADD CONSTRAINT "purchase_requisitions_approved_by_fkey" FOREIGN KEY ("approved_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_requisition_items" ADD CONSTRAINT "purchase_requisition_items_purchase_requisition_id_fkey" FOREIGN KEY ("purchase_requisition_id") REFERENCES "purchase_requisitions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_requisition_items" ADD CONSTRAINT "purchase_requisition_items_fabric_id_fkey" FOREIGN KEY ("fabric_id") REFERENCES "fabrics"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_requisition_items" ADD CONSTRAINT "purchase_requisition_items_trim_id_fkey" FOREIGN KEY ("trim_id") REFERENCES "trims"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_requisition_items" ADD CONSTRAINT "purchase_requisition_items_uom_id_fkey" FOREIGN KEY ("uom_id") REFERENCES "units_of_measure"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_orders" ADD CONSTRAINT "purchase_orders_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_orders" ADD CONSTRAINT "purchase_orders_supplier_id_fkey" FOREIGN KEY ("supplier_id") REFERENCES "suppliers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_orders" ADD CONSTRAINT "purchase_orders_purchase_requisition_id_fkey" FOREIGN KEY ("purchase_requisition_id") REFERENCES "purchase_requisitions"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_order_items" ADD CONSTRAINT "purchase_order_items_purchase_order_id_fkey" FOREIGN KEY ("purchase_order_id") REFERENCES "purchase_orders"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_order_items" ADD CONSTRAINT "purchase_order_items_fabric_id_fkey" FOREIGN KEY ("fabric_id") REFERENCES "fabrics"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_order_items" ADD CONSTRAINT "purchase_order_items_trim_id_fkey" FOREIGN KEY ("trim_id") REFERENCES "trims"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_order_items" ADD CONSTRAINT "purchase_order_items_uom_id_fkey" FOREIGN KEY ("uom_id") REFERENCES "units_of_measure"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "goods_receipt_notes" ADD CONSTRAINT "goods_receipt_notes_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "goods_receipt_notes" ADD CONSTRAINT "goods_receipt_notes_purchase_order_id_fkey" FOREIGN KEY ("purchase_order_id") REFERENCES "purchase_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "goods_receipt_notes" ADD CONSTRAINT "goods_receipt_notes_warehouse_id_fkey" FOREIGN KEY ("warehouse_id") REFERENCES "warehouses"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "goods_receipt_notes" ADD CONSTRAINT "goods_receipt_notes_received_by_fkey" FOREIGN KEY ("received_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "grn_items" ADD CONSTRAINT "grn_items_goods_receipt_note_id_fkey" FOREIGN KEY ("goods_receipt_note_id") REFERENCES "goods_receipt_notes"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "grn_items" ADD CONSTRAINT "grn_items_purchase_order_item_id_fkey" FOREIGN KEY ("purchase_order_item_id") REFERENCES "purchase_order_items"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "supplier_invoices" ADD CONSTRAINT "supplier_invoices_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "supplier_invoices" ADD CONSTRAINT "supplier_invoices_supplier_id_fkey" FOREIGN KEY ("supplier_id") REFERENCES "suppliers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "supplier_invoices" ADD CONSTRAINT "supplier_invoices_purchase_order_id_fkey" FOREIGN KEY ("purchase_order_id") REFERENCES "purchase_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "supplier_invoice_items" ADD CONSTRAINT "supplier_invoice_items_supplier_invoice_id_fkey" FOREIGN KEY ("supplier_invoice_id") REFERENCES "supplier_invoices"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "supplier_invoice_items" ADD CONSTRAINT "supplier_invoice_items_purchase_order_item_id_fkey" FOREIGN KEY ("purchase_order_item_id") REFERENCES "purchase_order_items"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "import_lc_references" ADD CONSTRAINT "import_lc_references_purchase_order_id_fkey" FOREIGN KEY ("purchase_order_id") REFERENCES "purchase_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "shipments" ADD CONSTRAINT "shipments_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "shipments" ADD CONSTRAINT "shipments_factory_id_fkey" FOREIGN KEY ("factory_id") REFERENCES "factories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "shipments" ADD CONSTRAINT "shipments_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "sales_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "shipment_cartons" ADD CONSTRAINT "shipment_cartons_shipment_id_fkey" FOREIGN KEY ("shipment_id") REFERENCES "shipments"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "shipment_cartons" ADD CONSTRAINT "shipment_cartons_carton_id_fkey" FOREIGN KEY ("carton_id") REFERENCES "cartons"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "commercial_invoices" ADD CONSTRAINT "commercial_invoices_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "commercial_invoices" ADD CONSTRAINT "commercial_invoices_shipment_id_fkey" FOREIGN KEY ("shipment_id") REFERENCES "shipments"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "commercial_invoices" ADD CONSTRAINT "commercial_invoices_buyer_id_fkey" FOREIGN KEY ("buyer_id") REFERENCES "buyers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "commercial_invoice_items" ADD CONSTRAINT "commercial_invoice_items_commercial_invoice_id_fkey" FOREIGN KEY ("commercial_invoice_id") REFERENCES "commercial_invoices"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "commercial_invoice_items" ADD CONSTRAINT "commercial_invoice_items_order_line_id_fkey" FOREIGN KEY ("order_line_id") REFERENCES "order_lines"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "shipment_packing_lists" ADD CONSTRAINT "shipment_packing_lists_shipment_id_fkey" FOREIGN KEY ("shipment_id") REFERENCES "shipments"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "exchange_rates" ADD CONSTRAINT "exchange_rates_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "exchange_rates" ADD CONSTRAINT "exchange_rates_from_currency_fkey" FOREIGN KEY ("from_currency") REFERENCES "currencies"("code") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "exchange_rates" ADD CONSTRAINT "exchange_rates_to_currency_fkey" FOREIGN KEY ("to_currency") REFERENCES "currencies"("code") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "chart_of_accounts" ADD CONSTRAINT "chart_of_accounts_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "chart_of_accounts" ADD CONSTRAINT "chart_of_accounts_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "companies"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "chart_of_accounts" ADD CONSTRAINT "chart_of_accounts_parent_account_id_fkey" FOREIGN KEY ("parent_account_id") REFERENCES "chart_of_accounts"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "journals" ADD CONSTRAINT "journals_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "journals" ADD CONSTRAINT "journals_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "companies"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "journals" ADD CONSTRAINT "journals_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "journals" ADD CONSTRAINT "journals_approved_by_fkey" FOREIGN KEY ("approved_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "journal_lines" ADD CONSTRAINT "journal_lines_journal_id_fkey" FOREIGN KEY ("journal_id") REFERENCES "journals"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "journal_lines" ADD CONSTRAINT "journal_lines_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "chart_of_accounts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "accounts_payable" ADD CONSTRAINT "accounts_payable_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "accounts_payable" ADD CONSTRAINT "accounts_payable_supplier_id_fkey" FOREIGN KEY ("supplier_id") REFERENCES "suppliers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "accounts_payable" ADD CONSTRAINT "accounts_payable_supplier_invoice_id_fkey" FOREIGN KEY ("supplier_invoice_id") REFERENCES "supplier_invoices"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "accounts_receivable" ADD CONSTRAINT "accounts_receivable_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "accounts_receivable" ADD CONSTRAINT "accounts_receivable_buyer_id_fkey" FOREIGN KEY ("buyer_id") REFERENCES "buyers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "accounts_receivable" ADD CONSTRAINT "accounts_receivable_commercial_invoice_id_fkey" FOREIGN KEY ("commercial_invoice_id") REFERENCES "commercial_invoices"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payments" ADD CONSTRAINT "payments_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_allocations" ADD CONSTRAINT "payment_allocations_accounts_payable_id_fkey" FOREIGN KEY ("accounts_payable_id") REFERENCES "accounts_payable"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payment_allocations" ADD CONSTRAINT "payment_allocations_accounts_receivable_id_fkey" FOREIGN KEY ("accounts_receivable_id") REFERENCES "accounts_receivable"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_costings" ADD CONSTRAINT "order_costings_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "sales_orders"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "employees" ADD CONSTRAINT "employees_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "employees" ADD CONSTRAINT "employees_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "companies"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "employees" ADD CONSTRAINT "employees_factory_id_fkey" FOREIGN KEY ("factory_id") REFERENCES "factories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "employees" ADD CONSTRAINT "employees_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "departments"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "employees" ADD CONSTRAINT "employees_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "attendance" ADD CONSTRAINT "attendance_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leave_types" ADD CONSTRAINT "leave_types_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leave_applications" ADD CONSTRAINT "leave_applications_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leave_applications" ADD CONSTRAINT "leave_applications_leave_type_id_fkey" FOREIGN KEY ("leave_type_id") REFERENCES "leave_types"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leave_applications" ADD CONSTRAINT "leave_applications_approved_by_fkey" FOREIGN KEY ("approved_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leave_balances" ADD CONSTRAINT "leave_balances_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "leave_balances" ADD CONSTRAINT "leave_balances_leave_type_id_fkey" FOREIGN KEY ("leave_type_id") REFERENCES "leave_types"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "salary_structures" ADD CONSTRAINT "salary_structures_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payroll_runs" ADD CONSTRAINT "payroll_runs_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payroll_runs" ADD CONSTRAINT "payroll_runs_factory_id_fkey" FOREIGN KEY ("factory_id") REFERENCES "factories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payroll_runs" ADD CONSTRAINT "payroll_runs_approved_by_fkey" FOREIGN KEY ("approved_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "compliance_schemes" ADD CONSTRAINT "compliance_schemes_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "compliance_audits" ADD CONSTRAINT "compliance_audits_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "compliance_audits" ADD CONSTRAINT "compliance_audits_factory_id_fkey" FOREIGN KEY ("factory_id") REFERENCES "factories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "certificates" ADD CONSTRAINT "certificates_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "certificates" ADD CONSTRAINT "certificates_factory_id_fkey" FOREIGN KEY ("factory_id") REFERENCES "factories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "attachments" ADD CONSTRAINT "attachments_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "attachments" ADD CONSTRAINT "attachments_uploaded_by_fkey" FOREIGN KEY ("uploaded_by") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "rag_documents" ADD CONSTRAINT "rag_documents_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ai_tool_call_logs" ADD CONSTRAINT "ai_tool_call_logs_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenants"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ai_tool_call_logs" ADD CONSTRAINT "ai_tool_call_logs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
