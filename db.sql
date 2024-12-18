-- Crear base de datos
CREATE DATABASE hr_management_system;

-- Usar la base de datos
USE hr_management_system;

-- Tabla de empresas
CREATE TABLE Companies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    taxId VARCHAR(50) UNIQUE NOT NULL,
    address TEXT,
    email VARCHAR(255),
    phone VARCHAR(20),
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabla de planes de pago
CREATE TABLE PaymentPlans (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL, -- Nombre del plan (Ej.: "Mensual", "Semestral")
    description TEXT, -- Detalles adicionales del plan
    durationInMonths INT NOT NULL, -- Duración del plan en meses
    price DECIMAL(10, 2) NOT NULL, -- Precio del plan
    isActive BOOLEAN DEFAULT TRUE, -- Si el plan está activo o no
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabla de suscripciones
CREATE TABLE Subscriptions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    companyId INT NOT NULL, -- Relación con la empresa
    planId INT NOT NULL, -- Relación con el plan de pago
    startDate DATE NOT NULL, -- Fecha de inicio de la suscripción
    endDate DATE NOT NULL, -- Fecha de finalización de la suscripción
    status ENUM('active', 'expired', 'canceled') DEFAULT 'active', -- Estado de la suscripción
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (companyId) REFERENCES Companies(id) ON DELETE CASCADE,
    FOREIGN KEY (planId) REFERENCES PaymentPlans(id) ON DELETE CASCADE
);

-- Tabla de métodos de pago
CREATE TABLE PaymentMethods (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL, -- Nombre del método de pago (Ej.: "Efectivo", "Stripe")
    description TEXT, -- Detalles adicionales del método de pago
    isActive BOOLEAN DEFAULT TRUE, -- Si el método de pago está activo o no
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabla de pagos
CREATE TABLE Payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    subscriptionId INT NOT NULL, -- Relación con la suscripción
    methodId INT NOT NULL, -- Relación con el método de pago
    amount DECIMAL(10, 2) NOT NULL, -- Monto del pago
    paymentDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Fecha y hora del pago
    status ENUM('pending', 'completed', 'failed') DEFAULT 'completed', -- Estado del pago
    transactionId VARCHAR(255), -- ID de transacción para pagos por API (Stripe, etc.)
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (subscriptionId) REFERENCES Subscriptions(id) ON DELETE CASCADE,
    FOREIGN KEY (methodId) REFERENCES PaymentMethods(id) ON DELETE CASCADE
);

-- Tabla de unidades de negocio (subempresas)
CREATE TABLE BusinessUnits (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    companyId INT NOT NULL, -- Relación con la empresa principal
    address TEXT,
    email VARCHAR(255),
    phone VARCHAR(20),
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (companyId) REFERENCES Companies(id) ON DELETE CASCADE
);

-- Tabla de departamentos
CREATE TABLE Departments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    businessUnitId INT NOT NULL, -- Relación con la unidad de negocio
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (businessUnitId) REFERENCES BusinessUnits(id) ON DELETE CASCADE
);

-- Tabla de roles de empleados
CREATE TABLE Roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    departmentId INT NOT NULL, -- Relación con el departamento
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (departmentId) REFERENCES Departments(id) ON DELETE CASCADE
);

-- Tabla de empleados
CREATE TABLE Employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    firstName VARCHAR(100) NOT NULL,
    lastName VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    hireDate DATE,
    status ENUM('active', 'inactive') DEFAULT 'active',
    businessUnitId INT NOT NULL, -- Unidad de negocio del empleado
    roleId INT NOT NULL, -- Rol del empleado
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (businessUnitId) REFERENCES BusinessUnits(id) ON DELETE CASCADE,
    FOREIGN KEY (roleId) REFERENCES Roles(id) ON DELETE CASCADE
);

-- Tabla de documentos requeridos
CREATE TABLE RequiredDocuments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    isMandatory BOOLEAN DEFAULT TRUE,
    companyId INT NOT NULL, -- Documentos pueden variar según la empresa
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (companyId) REFERENCES Companies(id) ON DELETE CASCADE
);

-- Tabla de documentos entregados por empleados
CREATE TABLE EmployeeDocuments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employeeId INT NOT NULL,
    documentId INT NOT NULL,
    submitted BOOLEAN DEFAULT FALSE,
    submissionDate DATE DEFAULT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (employeeId) REFERENCES Employees(id) ON DELETE CASCADE,
    FOREIGN KEY (documentId) REFERENCES RequiredDocuments(id) ON DELETE CASCADE
);

-- Tabla de pasos de onboarding
CREATE TABLE OnboardingSteps (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    isMandatory BOOLEAN DEFAULT TRUE,
    companyId INT NOT NULL, -- Pasos pueden variar según la empresa
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (companyId) REFERENCES Companies(id) ON DELETE CASCADE
);

-- Tabla de progreso del onboarding
CREATE TABLE EmployeeOnboarding (
    id INT AUTO_INCREMENT PRIMARY KEY,
    employeeId INT NOT NULL,
    stepId INT NOT NULL,
    completed BOOLEAN DEFAULT FALSE,
    completionDate DATE DEFAULT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (employeeId) REFERENCES Employees(id) ON DELETE CASCADE,
    FOREIGN KEY (stepId) REFERENCES OnboardingSteps(id) ON DELETE CASCADE
);
