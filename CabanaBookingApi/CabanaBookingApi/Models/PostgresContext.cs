using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace CabanaBookingApi.Models;

public partial class PostgresContext : DbContext
{
    public PostgresContext()
    {
    }

    public PostgresContext(DbContextOptions<PostgresContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Clienti> Clientis { get; set; }

    public virtual DbSet<RezervareServicii> RezervareServiciis { get; set; }

    public virtual DbSet<Rezervari> Rezervaris { get; set; }

    public virtual DbSet<ServiciiExtra> ServiciiExtras { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        if (!optionsBuilder.IsConfigured)
        {
            optionsBuilder.UseNpgsql("Name=DefaultConnection");
        }
    }
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder
            .HasPostgresEnum("auth", "aal_level", new[] { "aal1", "aal2", "aal3" })
            .HasPostgresEnum("auth", "code_challenge_method", new[] { "s256", "plain" })
            .HasPostgresEnum("auth", "factor_status", new[] { "unverified", "verified" })
            .HasPostgresEnum("auth", "factor_type", new[] { "totp", "webauthn", "phone" })
            .HasPostgresEnum("auth", "oauth_authorization_status", new[] { "pending", "approved", "denied", "expired" })
            .HasPostgresEnum("auth", "oauth_client_type", new[] { "public", "confidential" })
            .HasPostgresEnum("auth", "oauth_registration_type", new[] { "dynamic", "manual" })
            .HasPostgresEnum("auth", "oauth_response_type", new[] { "code" })
            .HasPostgresEnum("auth", "one_time_token_type", new[] { "confirmation_token", "reauthentication_token", "recovery_token", "email_change_token_new", "email_change_token_current", "phone_change_token" })
            .HasPostgresEnum("realtime", "action", new[] { "INSERT", "UPDATE", "DELETE", "TRUNCATE", "ERROR" })
            .HasPostgresEnum("realtime", "equality_op", new[] { "eq", "neq", "lt", "lte", "gt", "gte", "in", "like", "ilike", "is", "match", "imatch", "isdistinct" })
            .HasPostgresEnum("storage", "buckettype", new[] { "STANDARD", "ANALYTICS", "VECTOR" })
            .HasPostgresExtension("extensions", "pg_stat_statements")
            .HasPostgresExtension("extensions", "pgcrypto")
            .HasPostgresExtension("extensions", "uuid-ossp")
            .HasPostgresExtension("vault", "supabase_vault");

        modelBuilder.Entity<Clienti>(entity =>
        {
            entity.HasKey(e => e.IdClient).HasName("clienti_pkey");

            entity.ToTable("clienti");

            entity.Property(e => e.IdClient).HasColumnName("id_client");
            entity.Property(e => e.Cnp)
                .HasMaxLength(13)
                .HasColumnName("cnp");
            entity.Property(e => e.DataInregistrare)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("data_inregistrare");
            entity.Property(e => e.Email)
                .HasMaxLength(100)
                .HasColumnName("email");
            entity.Property(e => e.Nume)
                .HasMaxLength(50)
                .HasColumnName("nume");
            entity.Property(e => e.Prenume)
                .HasMaxLength(50)
                .HasColumnName("prenume");
            entity.Property(e => e.Telefon)
                .HasMaxLength(20)
                .HasColumnName("telefon");
        });

        modelBuilder.Entity<RezervareServicii>(entity =>
        {
            entity.HasKey(e => new { e.IdRezervare, e.IdServiciu }).HasName("rezervare_servicii_pkey");

            entity.ToTable("rezervare_servicii");

            entity.Property(e => e.IdRezervare).HasColumnName("id_rezervare");
            entity.Property(e => e.IdServiciu).HasColumnName("id_serviciu");
            entity.Property(e => e.Done)
                .HasDefaultValue((short)0)
                .HasColumnName("done");

            entity.HasOne(d => d.IdRezervareNavigation).WithMany(p => p.RezervareServiciis)
                .HasForeignKey(d => d.IdRezervare)
                .HasConstraintName("rezervare_servicii_id_rezervare_fkey");

            entity.HasOne(d => d.IdServiciuNavigation).WithMany(p => p.RezervareServiciis)
                .HasForeignKey(d => d.IdServiciu)
                .HasConstraintName("rezervare_servicii_id_serviciu_fkey");
        });

        modelBuilder.Entity<Rezervari>(entity =>
        {
            entity.HasKey(e => e.IdRezervare).HasName("rezervari_pkey");

            entity.ToTable("rezervari");

            entity.Property(e => e.IdRezervare).HasColumnName("id_rezervare");
            entity.Property(e => e.DataCheckin)
                .HasColumnType("timestamp without time zone")
                .HasColumnName("data_checkin");
            entity.Property(e => e.DataCheckout)
                .HasColumnType("timestamp without time zone")
                .HasColumnName("data_checkout");
            entity.Property(e => e.DataCreare)
                .HasDefaultValueSql("CURRENT_TIMESTAMP")
                .HasColumnType("timestamp without time zone")
                .HasColumnName("data_creare");
            entity.Property(e => e.IdClient).HasColumnName("id_client");
            entity.Property(e => e.IsNew)
                .HasDefaultValue((short)1)
                .HasColumnName("is_new");
            entity.Property(e => e.Notite)
                .HasMaxLength(500)
                .HasColumnName("notite");
            entity.Property(e => e.PaymentStatus)
                .HasMaxLength(30)
                .HasDefaultValueSql("'Neachitat'::character varying")
                .HasColumnName("payment_status");
            entity.Property(e => e.PretTotal)
                .HasPrecision(8, 2)
                .HasColumnName("pret_total");
            entity.Property(e => e.Status)
                .HasMaxLength(20)
                .HasDefaultValueSql("'CONFIRMATA'::character varying")
                .HasColumnName("status");

            entity.HasOne(d => d.IdClientNavigation).WithMany(p => p.Rezervaris)
                .HasForeignKey(d => d.IdClient)
                .HasConstraintName("rezervari_id_client_fkey");
        });

        modelBuilder.Entity<ServiciiExtra>(entity =>
        {
            entity.HasKey(e => e.IdServiciu).HasName("servicii_extra_pkey");

            entity.ToTable("servicii_extra");

            entity.Property(e => e.IdServiciu).HasColumnName("id_serviciu");
            entity.Property(e => e.Activ)
                .HasDefaultValue((short)1)
                .HasColumnName("activ");
            entity.Property(e => e.Denumire)
                .HasMaxLength(100)
                .HasColumnName("denumire");
            entity.Property(e => e.Pret)
                .HasPrecision(8, 2)
                .HasColumnName("pret");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
