using CabanaBookingApi.Models; // Namespace-ul pentru modelele generate în folderul Models
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Adaugă conexiunea la baza de date Supabase (PostgreSQL)
builder.Services.AddDbContext<PostgresContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

// Adaugă Controller-ele
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Permite apelarea API-ului din browser/site web (CORS)
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

// Activează politica CORS
app.UseCors("AllowAll");

app.UseAuthorization();

app.MapControllers();

app.Run();