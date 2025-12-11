
CREATE TABLE IF NOT EXISTS public.academic_member
(
    academic_member_id uuid NOT NULL DEFAULT gen_random_uuid(),
    first_name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    last_name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    birthdate date NOT NULL,
    username character varying(100) COLLATE pg_catalog."default" NOT NULL,
    password_hash character varying(255) COLLATE pg_catalog."default" NOT NULL,
    email character varying(255) COLLATE pg_catalog."default" NOT NULL,
    email_verified boolean NOT NULL DEFAULT false,
    phone character varying(20) COLLATE pg_catalog."default" NOT NULL,
    device_id character varying(255) COLLATE pg_catalog."default" NOT NULL,
    university_number character varying(50) COLLATE pg_catalog."default" NOT NULL,
    soft_delete boolean NOT NULL DEFAULT false,
    academic_year_id uuid NOT NULL,
    role_id uuid NOT NULL,
    university_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT academic_member_pkey PRIMARY KEY (academic_member_id),
    CONSTRAINT academic_member_email_key UNIQUE (email),
    CONSTRAINT academic_member_university_number_key UNIQUE (university_number),
    CONSTRAINT academic_member_username_key UNIQUE (username)
);

COMMENT ON TABLE public.academic_member
    IS 'Stores academic members information (students, instructors, admins)';

COMMENT ON COLUMN public.academic_member.academic_member_id
    IS 'Unique identifier for academic member';

COMMENT ON COLUMN public.academic_member.first_name
    IS 'First name';

COMMENT ON COLUMN public.academic_member.last_name
    IS 'Last name';

COMMENT ON COLUMN public.academic_member.birthdate
    IS 'Date of birth';

COMMENT ON COLUMN public.academic_member.username
    IS 'Unique username for login';

COMMENT ON COLUMN public.academic_member.password_hash
    IS 'Hashed password';

COMMENT ON COLUMN public.academic_member.email
    IS 'Email address';

COMMENT ON COLUMN public.academic_member.email_verified
    IS 'Email verification status';

COMMENT ON COLUMN public.academic_member.phone
    IS 'Phone number';

COMMENT ON COLUMN public.academic_member.university_number
    IS 'University identification number';

COMMENT ON COLUMN public.academic_member.soft_delete
    IS 'Soft delete flag';

COMMENT ON COLUMN public.academic_member.academic_year_id
    IS 'Reference to academic year';

COMMENT ON COLUMN public.academic_member.role_id
    IS 'Reference to role';

COMMENT ON COLUMN public.academic_member.university_id
    IS 'Reference to university';

COMMENT ON COLUMN public.academic_member.created_at
    IS 'Timestamp when record was created';

COMMENT ON COLUMN public.academic_member.updated_at
    IS 'Timestamp when record was last updated';

CREATE TABLE IF NOT EXISTS public.academic_year
(
    academic_year_id uuid NOT NULL DEFAULT gen_random_uuid(),
    code character varying(50) COLLATE pg_catalog."default" NOT NULL,
    description character varying(500) COLLATE pg_catalog."default" NOT NULL,
    soft_delete boolean NOT NULL DEFAULT false,
    created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT academic_year_pkey PRIMARY KEY (academic_year_id),
    CONSTRAINT academic_year_code_key UNIQUE (code)
);

COMMENT ON TABLE public.academic_year
    IS 'Stores academic year information';

COMMENT ON COLUMN public.academic_year.academic_year_id
    IS 'Unique identifier for academic year';

COMMENT ON COLUMN public.academic_year.code
    IS 'Academic year code (e.g., 2024-2025)';

COMMENT ON COLUMN public.academic_year.description
    IS 'Academic year description';

COMMENT ON COLUMN public.academic_year.soft_delete
    IS 'Soft delete flag';

COMMENT ON COLUMN public.academic_year.created_at
    IS 'Timestamp when record was created';

COMMENT ON COLUMN public.academic_year.updated_at
    IS 'Timestamp when record was last updated';

CREATE TABLE IF NOT EXISTS public.attendance
(
    attendance_id uuid NOT NULL DEFAULT gen_random_uuid(),
    check_in_time timestamp with time zone NOT NULL,
    ip_address character varying(50) COLLATE pg_catalog."default" NOT NULL,
    device_id character varying(255) COLLATE pg_catalog."default" NOT NULL,
    is_present boolean NOT NULL DEFAULT false,
    location_verified boolean NOT NULL DEFAULT false,
    lecture_id uuid NOT NULL,
    qr_code_id uuid NOT NULL,
    student_academic_member_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT attendance_pkey PRIMARY KEY (attendance_id),
    CONSTRAINT uq_student_lecture UNIQUE (student_academic_member_id, lecture_id)
);

COMMENT ON TABLE public.attendance
    IS 'Stores student attendance records';

COMMENT ON COLUMN public.attendance.attendance_id
    IS 'Unique identifier for attendance record';

COMMENT ON COLUMN public.attendance.check_in_time
    IS 'Timestamp when student checked in';

COMMENT ON COLUMN public.attendance.ip_address
    IS 'IP address of device used for check-in';

COMMENT ON COLUMN public.attendance.device_id
    IS 'Device identifier used for check-in';

COMMENT ON COLUMN public.attendance.is_present
    IS 'Flag indicating if student is marked present';

COMMENT ON COLUMN public.attendance.location_verified
    IS 'Flag indicating if location was verified';

COMMENT ON COLUMN public.attendance.lecture_id
    IS 'Reference to lecture';

COMMENT ON COLUMN public.attendance.qr_code_id
    IS 'Reference to QR code used';

COMMENT ON COLUMN public.attendance.student_academic_member_id
    IS 'Reference to student';

COMMENT ON COLUMN public.attendance.created_at
    IS 'Timestamp when record was created';

COMMENT ON COLUMN public.attendance.updated_at
    IS 'Timestamp when record was last updated';

CREATE TABLE IF NOT EXISTS public.course
(
    course_id uuid NOT NULL DEFAULT gen_random_uuid(),
    code character varying(50) COLLATE pg_catalog."default" NOT NULL,
    name character varying(255) COLLATE pg_catalog."default" NOT NULL,
    description text COLLATE pg_catalog."default",
    soft_delete boolean NOT NULL DEFAULT false,
    university_id uuid NOT NULL,
    academic_year_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT course_pkey PRIMARY KEY (course_id),
    CONSTRAINT uq_course_code_university_year UNIQUE (code, university_id, academic_year_id)
);

COMMENT ON TABLE public.course
    IS 'Stores course information';

COMMENT ON COLUMN public.course.course_id
    IS 'Unique identifier for course';

COMMENT ON COLUMN public.course.code
    IS 'Course code';

COMMENT ON COLUMN public.course.name
    IS 'Course name';

COMMENT ON COLUMN public.course.description
    IS 'Course description';

COMMENT ON COLUMN public.course.soft_delete
    IS 'Soft delete flag';

COMMENT ON COLUMN public.course.university_id
    IS 'Reference to university';

COMMENT ON COLUMN public.course.academic_year_id
    IS 'Reference to academic year';

COMMENT ON COLUMN public.course.created_at
    IS 'Timestamp when record was created';

COMMENT ON COLUMN public.course.updated_at
    IS 'Timestamp when record was last updated';

CREATE TABLE IF NOT EXISTS public.course_instructor
(
    course_instructor_id uuid NOT NULL DEFAULT gen_random_uuid(),
    instructor_academic_member_id uuid NOT NULL,
    course_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT course_instructor_pkey PRIMARY KEY (course_instructor_id),
    CONSTRAINT uq_instructor_course UNIQUE (instructor_academic_member_id, course_id)
);

COMMENT ON TABLE public.course_instructor
    IS 'Junction table linking instructors to courses';

COMMENT ON COLUMN public.course_instructor.course_instructor_id
    IS 'Unique identifier for course instructor relationship';

COMMENT ON COLUMN public.course_instructor.instructor_academic_member_id
    IS 'Reference to instructor (academic member)';

COMMENT ON COLUMN public.course_instructor.course_id
    IS 'Reference to course';

COMMENT ON COLUMN public.course_instructor.created_at
    IS 'Timestamp when record was created';

COMMENT ON COLUMN public.course_instructor.updated_at
    IS 'Timestamp when record was last updated';

CREATE TABLE IF NOT EXISTS public.enrollment
(
    enrollment_id uuid NOT NULL DEFAULT gen_random_uuid(),
    soft_delete boolean NOT NULL DEFAULT false,
    course_id uuid NOT NULL,
    student_academic_member uuid NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT enrollment_pkey PRIMARY KEY (enrollment_id),
    CONSTRAINT uq_student_course UNIQUE (student_academic_member, course_id)
);

COMMENT ON TABLE public.enrollment
    IS 'Stores student enrollments in courses';

COMMENT ON COLUMN public.enrollment.enrollment_id
    IS 'Unique identifier for enrollment';

COMMENT ON COLUMN public.enrollment.soft_delete
    IS 'Soft delete flag';

COMMENT ON COLUMN public.enrollment.course_id
    IS 'Reference to course';

COMMENT ON COLUMN public.enrollment.student_academic_member
    IS 'Reference to student (academic member)';

COMMENT ON COLUMN public.enrollment.created_at
    IS 'Timestamp when record was created';

COMMENT ON COLUMN public.enrollment.updated_at
    IS 'Timestamp when record was last updated';

CREATE TABLE IF NOT EXISTS public.flyway_schema_history
(
    installed_rank integer NOT NULL,
    version character varying(50) COLLATE pg_catalog."default",
    description character varying(200) COLLATE pg_catalog."default" NOT NULL,
    type character varying(20) COLLATE pg_catalog."default" NOT NULL,
    script character varying(1000) COLLATE pg_catalog."default" NOT NULL,
    checksum integer,
    installed_by character varying(100) COLLATE pg_catalog."default" NOT NULL,
    installed_on timestamp without time zone NOT NULL DEFAULT now(),
    execution_time integer NOT NULL,
    success boolean NOT NULL,
    CONSTRAINT flyway_schema_history_pk PRIMARY KEY (installed_rank)
);

CREATE TABLE IF NOT EXISTS public.lecture
(
    lecture_id uuid NOT NULL DEFAULT gen_random_uuid(),
    lecture_date date NOT NULL,
    day_of_week character varying(20) COLLATE pg_catalog."default" NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL,
    room character varying(50) COLLATE pg_catalog."default" NOT NULL,
    status boolean NOT NULL DEFAULT true,
    soft_delete boolean NOT NULL DEFAULT false,
    course_id uuid NOT NULL,
    instructor_academic_member_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT lecture_pkey PRIMARY KEY (lecture_id)
);

COMMENT ON TABLE public.lecture
    IS 'Stores lecture sessions';

COMMENT ON COLUMN public.lecture.lecture_id
    IS 'Unique identifier for lecture';

COMMENT ON COLUMN public.lecture.lecture_date
    IS 'Date of the lecture';

COMMENT ON COLUMN public.lecture.day_of_week
    IS 'Day of the week (MONDAY, TUESDAY, etc.)';

COMMENT ON COLUMN public.lecture.start_time
    IS 'Lecture start time';

COMMENT ON COLUMN public.lecture.end_time
    IS 'Lecture end time';

COMMENT ON COLUMN public.lecture.room
    IS 'Room number or location';

COMMENT ON COLUMN public.lecture.status
    IS 'Lecture status (active/inactive)';

COMMENT ON COLUMN public.lecture.soft_delete
    IS 'Soft delete flag';

COMMENT ON COLUMN public.lecture.course_id
    IS 'Reference to course';

COMMENT ON COLUMN public.lecture.instructor_academic_member_id
    IS 'Reference to instructor';

COMMENT ON COLUMN public.lecture.created_at
    IS 'Timestamp when record was created';

COMMENT ON COLUMN public.lecture.updated_at
    IS 'Timestamp when record was last updated';

CREATE TABLE IF NOT EXISTS public.notification
(
    notification_id uuid NOT NULL DEFAULT gen_random_uuid(),
    message text COLLATE pg_catalog."default" NOT NULL,
    type notification_type NOT NULL,
    is_read boolean NOT NULL DEFAULT false,
    academic_member_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT notification_pkey PRIMARY KEY (notification_id)
);

COMMENT ON TABLE public.notification
    IS 'Stores notifications for academic members';

COMMENT ON COLUMN public.notification.notification_id
    IS 'Unique identifier for notification';

COMMENT ON COLUMN public.notification.message
    IS 'Notification message content';

COMMENT ON COLUMN public.notification.type
    IS 'Notification type (ALERT, WARNING, INFO, REMINDER)';

COMMENT ON COLUMN public.notification.is_read
    IS 'Flag indicating if notification has been read';

COMMENT ON COLUMN public.notification.academic_member_id
    IS 'Reference to academic member';

COMMENT ON COLUMN public.notification.created_at
    IS 'Timestamp when record was created';

COMMENT ON COLUMN public.notification.updated_at
    IS 'Timestamp when record was last updated';

CREATE TABLE IF NOT EXISTS public.qr_code
(
    qr_code_id uuid NOT NULL DEFAULT gen_random_uuid(),
    uuid_token_hash character varying(255) COLLATE pg_catalog."default" NOT NULL,
    network_info character varying(500) COLLATE pg_catalog."default" NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    duration_seconds bigint NOT NULL,
    activated boolean NOT NULL DEFAULT true,
    expired boolean NOT NULL DEFAULT false,
    lecture_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT qr_code_pkey PRIMARY KEY (qr_code_id),
    CONSTRAINT qr_code_uuid_token_hash_key UNIQUE (uuid_token_hash)
);

COMMENT ON TABLE public.qr_code
    IS 'Stores QR codes for attendance verification';

COMMENT ON COLUMN public.qr_code.qr_code_id
    IS 'Unique identifier for QR code';

COMMENT ON COLUMN public.qr_code.uuid_token_hash
    IS 'Hashed UUID token for QR code';

COMMENT ON COLUMN public.qr_code.network_info
    IS 'Network information for location verification';

COMMENT ON COLUMN public.qr_code.expires_at
    IS 'Expiration timestamp';

COMMENT ON COLUMN public.qr_code.duration_seconds
    IS 'Duration in seconds before expiration';

COMMENT ON COLUMN public.qr_code.activated
    IS 'QR code activation status';

COMMENT ON COLUMN public.qr_code.expired
    IS 'QR code expiration status';

COMMENT ON COLUMN public.qr_code.lecture_id
    IS 'Reference to lecture';

COMMENT ON COLUMN public.qr_code.created_at
    IS 'Timestamp when record was created';

COMMENT ON COLUMN public.qr_code.updated_at
    IS 'Timestamp when record was last updated';

CREATE TABLE IF NOT EXISTS public.roles
(
    role_id uuid NOT NULL DEFAULT gen_random_uuid(),
    name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    description character varying(500) COLLATE pg_catalog."default",
    soft_delete boolean NOT NULL DEFAULT false,
    created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT roles_pkey PRIMARY KEY (role_id),
    CONSTRAINT roles_name_key UNIQUE (name)
);

COMMENT ON TABLE public.roles
    IS 'Stores user roles information';

COMMENT ON COLUMN public.roles.role_id
    IS 'Unique identifier for role';

COMMENT ON COLUMN public.roles.name
    IS 'Role name (e.g., STUDENT, INSTRUCTOR, ADMIN)';

COMMENT ON COLUMN public.roles.description
    IS 'Role description';

COMMENT ON COLUMN public.roles.soft_delete
    IS 'Soft delete flag';

COMMENT ON COLUMN public.roles.created_at
    IS 'Timestamp when record was created';

COMMENT ON COLUMN public.roles.updated_at
    IS 'Timestamp when record was last updated';

CREATE TABLE IF NOT EXISTS public.university
(
    universities_id uuid NOT NULL DEFAULT gen_random_uuid(),
    name character varying(255) COLLATE pg_catalog."default" NOT NULL,
    location character varying(500) COLLATE pg_catalog."default" NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT university_pkey PRIMARY KEY (universities_id)
);

COMMENT ON TABLE public.university
    IS 'Stores university information';

COMMENT ON COLUMN public.university.universities_id
    IS 'Unique identifier for university';

COMMENT ON COLUMN public.university.name
    IS 'University name';

COMMENT ON COLUMN public.university.location
    IS 'University location';

COMMENT ON COLUMN public.university.created_at
    IS 'Timestamp when record was created';

COMMENT ON COLUMN public.university.updated_at
    IS 'Timestamp when record was last updated';

ALTER TABLE IF EXISTS public.academic_member
    ADD CONSTRAINT fk_academic_member_academic_year FOREIGN KEY (academic_year_id)
    REFERENCES public.academic_year (academic_year_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE RESTRICT;
CREATE INDEX IF NOT EXISTS idx_academic_member_academic_year_id
    ON public.academic_member(academic_year_id);


ALTER TABLE IF EXISTS public.academic_member
    ADD CONSTRAINT fk_academic_member_role FOREIGN KEY (role_id)
    REFERENCES public.roles (role_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE RESTRICT;
CREATE INDEX IF NOT EXISTS idx_academic_member_role_id
    ON public.academic_member(role_id);


ALTER TABLE IF EXISTS public.academic_member
    ADD CONSTRAINT fk_academic_member_university FOREIGN KEY (university_id)
    REFERENCES public.university (universities_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE RESTRICT;
CREATE INDEX IF NOT EXISTS idx_academic_member_university_id
    ON public.academic_member(university_id);


ALTER TABLE IF EXISTS public.attendance
    ADD CONSTRAINT fk_attendance_lecture FOREIGN KEY (lecture_id)
    REFERENCES public.lecture (lecture_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_attendance_lecture_id
    ON public.attendance(lecture_id);


ALTER TABLE IF EXISTS public.attendance
    ADD CONSTRAINT fk_attendance_qr_code FOREIGN KEY (qr_code_id)
    REFERENCES public.qr_code (qr_code_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE RESTRICT;
CREATE INDEX IF NOT EXISTS idx_attendance_qr_code_id
    ON public.attendance(qr_code_id);


ALTER TABLE IF EXISTS public.attendance
    ADD CONSTRAINT fk_attendance_student FOREIGN KEY (student_academic_member_id)
    REFERENCES public.academic_member (academic_member_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_attendance_student_id
    ON public.attendance(student_academic_member_id);


ALTER TABLE IF EXISTS public.course
    ADD CONSTRAINT fk_course_academic_year FOREIGN KEY (academic_year_id)
    REFERENCES public.academic_year (academic_year_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE RESTRICT;
CREATE INDEX IF NOT EXISTS idx_course_academic_year_id
    ON public.course(academic_year_id);


ALTER TABLE IF EXISTS public.course
    ADD CONSTRAINT fk_course_university FOREIGN KEY (university_id)
    REFERENCES public.university (universities_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE RESTRICT;
CREATE INDEX IF NOT EXISTS idx_course_university_id
    ON public.course(university_id);


ALTER TABLE IF EXISTS public.course_instructor
    ADD CONSTRAINT fk_course_instructor_academic_member FOREIGN KEY (instructor_academic_member_id)
    REFERENCES public.academic_member (academic_member_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_course_instructor_academic_member_id
    ON public.course_instructor(instructor_academic_member_id);


ALTER TABLE IF EXISTS public.course_instructor
    ADD CONSTRAINT fk_course_instructor_course FOREIGN KEY (course_id)
    REFERENCES public.course (course_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_course_instructor_course_id
    ON public.course_instructor(course_id);


ALTER TABLE IF EXISTS public.enrollment
    ADD CONSTRAINT fk_enrollment_course FOREIGN KEY (course_id)
    REFERENCES public.course (course_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_enrollment_course_id
    ON public.enrollment(course_id);


ALTER TABLE IF EXISTS public.enrollment
    ADD CONSTRAINT fk_enrollment_student FOREIGN KEY (student_academic_member)
    REFERENCES public.academic_member (academic_member_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_enrollment_student_academic_member
    ON public.enrollment(student_academic_member);


ALTER TABLE IF EXISTS public.lecture
    ADD CONSTRAINT fk_lecture_course FOREIGN KEY (course_id)
    REFERENCES public.course (course_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_lecture_course_id
    ON public.lecture(course_id);


ALTER TABLE IF EXISTS public.lecture
    ADD CONSTRAINT fk_lecture_instructor FOREIGN KEY (instructor_academic_member_id)
    REFERENCES public.academic_member (academic_member_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE RESTRICT;
CREATE INDEX IF NOT EXISTS idx_lecture_instructor_id
    ON public.lecture(instructor_academic_member_id);


ALTER TABLE IF EXISTS public.notification
    ADD CONSTRAINT fk_notification_academic_member FOREIGN KEY (academic_member_id)
    REFERENCES public.academic_member (academic_member_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_notification_academic_member_id
    ON public.notification(academic_member_id);


ALTER TABLE IF EXISTS public.qr_code
    ADD CONSTRAINT fk_qr_code_lecture FOREIGN KEY (lecture_id)
    REFERENCES public.lecture (lecture_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_qr_code_lecture_id
    ON public.qr_code(lecture_id);

END;