# Quick Reference Guide

## Initial Setup

```bash
./setup.sh
# Choose option 4 to initialize environment
```

## Adding a Site

```bash
./setup.sh
# Choose option 1
# Follow prompts for site name, domain, PHP version, database
```

## Common Commands

### Site Management
```bash
./setup.sh                    # Interactive menu
```

### Docker Operations
```bash
docker compose up -d          # Start containers
docker compose down           # Stop containers
docker compose ps             # List running containers
docker compose logs -f        # View logs
docker compose restart nginx  # Restart nginx
```

### Running Commands in Sites

```bash
# Artisan commands (replace php84 with your PHP version)
docker compose exec php84 php /var/www/sites/SITENAME/artisan migrate
docker compose exec php84 php /var/www/sites/SITENAME/artisan db:seed
docker compose exec php84 php /var/www/sites/SITENAME/artisan cache:clear

# Composer commands
docker compose exec php84 composer install -d /var/www/sites/SITENAME
docker compose exec php84 composer update -d /var/www/sites/SITENAME
docker compose exec php84 composer require package/name -d /var/www/sites/SITENAME

# NPM commands (if npm is installed in PHP container)
docker compose exec php84 bash
cd /var/www/sites/SITENAME
npm install
npm run dev
```

### MySQL Access

```bash
# Access MySQL CLI
docker compose exec mysql mysql -u root -p

# Import database
docker compose exec -T mysql mysql -u root -p < backup.sql

# Export database
docker compose exec mysql mysqldump -u root -p database_name > backup.sql
```

## Directory Structure

```
sites/
├── site1/          # Laravel app 1
├── site2/          # Laravel app 2
└── site3/          # Laravel app 3

config/vhosts/
├── site1.conf      # Nginx config for site1
├── site2.conf      # Nginx config for site2
└── site3.conf      # Nginx config for site3
```

## PHP Container Names

- `php81` - PHP 8.1
- `php82` - PHP 8.2
- `php83` - PHP 8.3
- `php84` - PHP 8.4

## Service Names

- `webserver` - Nginx
- `mysql` - MySQL 8.0
- `redis` - Redis 7

## Hosts File

Add to `/etc/hosts`:
```
127.0.0.1  site1.test
127.0.0.1  site2.test
127.0.0.1  site3.test
```

## Troubleshooting

### Reload Nginx
```bash
docker compose exec webserver nginx -s reload
```

### Check Nginx Config
```bash
docker compose exec webserver nginx -t
```

### Fix Permissions
```bash
sudo chown -R $USER:$USER sites/
```

### View Container Logs
```bash
docker compose logs webserver
docker compose logs mysql
docker compose logs php84
```
