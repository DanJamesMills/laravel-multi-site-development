<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Site Configured Successfully</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Inter', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #0F172A 0%, #1E293B 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            color: #E2E8F0;
        }
        .container {
            background: linear-gradient(135deg, #1E293B 0%, #0F172A 100%);
            border: 1px solid rgba(59, 130, 246, 0.2);
            border-radius: 20px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
            padding: 60px;
            max-width: 700px;
            width: 100%;
            position: relative;
            overflow: hidden;
        }
        .container::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, #3B82F6 0%, #8B5CF6 50%, #EC4899 100%);
        }
        .logo-area {
            text-align: center;
            margin-bottom: 40px;
        }
        .icon-container {
            display: inline-block;
            position: relative;
            margin-bottom: 20px;
        }
        .icon-box {
            width: 50px;
            height: 50px;
            border: 3px solid;
            border-radius: 8px;
            position: absolute;
            opacity: 0.8;
        }
        .icon-box:nth-child(1) { border-color: #3B82F6; top: 0; left: 0; }
        .icon-box:nth-child(2) { border-color: #8B5CF6; top: 10px; left: 10px; }
        .icon-box:nth-child(3) { border-color: #EC4899; top: 20px; left: 20px; }
        .success-icon {
            width: 70px;
            height: 70px;
            background: linear-gradient(135deg, #3B82F6, #8B5CF6);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 30px;
            font-size: 40px;
            position: relative;
            animation: pulse 2s ease-in-out infinite;
        }
        @keyframes pulse {
            0%, 100% { box-shadow: 0 0 0 0 rgba(59, 130, 246, 0.7); }
            50% { box-shadow: 0 0 0 15px rgba(59, 130, 246, 0); }
        }
        h1 {
            background: linear-gradient(90deg, #3B82F6, #8B5CF6, #EC4899);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            font-size: 32px;
            font-weight: 700;
            margin-bottom: 10px;
            text-align: center;
        }
        .subtitle {
            color: #94A3B8;
            text-align: center;
            margin-bottom: 30px;
            font-size: 15px;
        }
        .info-box {
            background: rgba(30, 41, 59, 0.5);
            border: 1px solid rgba(59, 130, 246, 0.2);
            border-radius: 12px;
            padding: 25px;
            margin: 25px 0;
            backdrop-filter: blur(10px);
        }
        .info-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px solid rgba(148, 163, 184, 0.1);
        }
        .info-row:last-child { border-bottom: none; }
        .label { 
            font-weight: 600; 
            color: #94A3B8;
            font-size: 14px;
        }
        .value { 
            color: #E2E8F0; 
            font-family: 'SF Mono', 'Monaco', 'Cascadia Code', monospace;
            font-size: 13px;
        }
        .php-badge {
            display: inline-block;
            background: linear-gradient(135deg, #8B5CF6, #3B82F6);
            color: white;
            padding: 6px 16px;
            border-radius: 20px;
            font-weight: 600;
            font-size: 13px;
            box-shadow: 0 4px 6px rgba(139, 92, 246, 0.3);
        }
        .status-badge {
            display: inline-block;
            background: linear-gradient(135deg, #10B981, #059669);
            color: white;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
        }
        details {
            margin: 20px 0;
            background: rgba(30, 41, 59, 0.5);
            border: 1px solid rgba(59, 130, 246, 0.2);
            border-radius: 12px;
            overflow: hidden;
            backdrop-filter: blur(10px);
            text-align: left;
        }
        summary {
            cursor: pointer;
            padding: 15px;
            font-weight: 600;
            color: #CBD5E1;
            background: transparent;
            user-select: none;
            transition: all 0.3s;
            list-style: none;
        }
        summary::-webkit-details-marker {
            display: none;
        }
        summary:hover {
            color: #3B82F6;
        }
        .extensions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(110px, 1fr));
            gap: 8px;
            padding: 15px;
            background: transparent;
        }
        .ext-item {
            background: linear-gradient(135deg, #8B5CF6, #3B82F6);
            border: none;
            padding: 8px 12px;
            border-radius: 6px;
            font-size: 11px;
            color: white;
            text-align: center;
            font-weight: 500;
            transition: all 0.2s;
            box-shadow: 0 2px 4px rgba(139, 92, 246, 0.2);
        }
        .ext-item:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(139, 92, 246, 0.4);
        }
        code {
            background: rgba(59, 130, 246, 0.1);
            color: #3B82F6;
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 13px;
            font-family: 'SF Mono', 'Monaco', 'Cascadia Code', monospace;
            border: 1px solid rgba(59, 130, 246, 0.2);
        }
        .credentials-box {
            border: 2px solid #3B82F6;
            background: linear-gradient(135deg, rgba(59, 130, 246, 0.1), rgba(139, 92, 246, 0.1));
            border-radius: 12px;
            padding: 20px;
            margin: 25px 0;
        }
        .credentials-title {
            font-weight: 700;
            color: #3B82F6;
            margin-bottom: 15px;
            font-size: 16px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .credentials-subtitle {
            font-size: 13px;
            color: #94A3B8;
            margin-bottom: 15px;
        }
        .note-box {
            background: linear-gradient(135deg, rgba(245, 158, 11, 0.1), rgba(251, 146, 60, 0.1));
            border-left: 4px solid #F59E0B;
            padding: 20px;
            margin-top: 25px;
            border-radius: 8px;
            color: #FDE68A;
        }
        .note-box strong {
            color: #FCD34D;
            display: block;
            margin-bottom: 10px;
        }
        .tip-box {
            text-align: center;
            margin-top: 30px;
            padding: 15px;
            background: rgba(59, 130, 246, 0.05);
            border-radius: 8px;
            border: 1px solid rgba(59, 130, 246, 0.1);
        }
        .tip-box small {
            color: #64748B;
            font-size: 13px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo-area">
            <div class="icon-container" style="width: 70px; height: 70px; margin: 0 auto;">
                <div class="icon-box"></div>
                <div class="icon-box"></div>
                <div class="icon-box"></div>
            </div>
        </div>
        
        <div class="success-icon">✓</div>
        <h1>Site Configured Successfully!</h1>
        <p class="subtitle">Your development environment is ready and running</p>
        
        <div class="info-box">
            <div class="info-row">
                <span class="label">Site Name:</span>
                <span class="value">{SITE_NAME}</span>
            </div>
            <div class="info-row">
                <span class="label">Domain:</span>
                <span class="value">{DOMAIN}</span>
            </div>
            <div class="info-row">
                <span class="label">PHP Version:</span>
                <span class="value">
                    <span class="php-badge">PHP <?php echo phpversion(); ?></span>
                </span>
            </div>
            <div class="info-row">
                <span class="label">Server:</span>
                <span class="value"><?php echo $_SERVER['SERVER_SOFTWARE'] ?? 'nginx'; ?></span>
            </div>
            <div class="info-row">
                <span class="label">Document Root:</span>
                <span class="value"><?php echo $_SERVER['DOCUMENT_ROOT']; ?></span>
            </div>
            <div class="info-row">
                <span class="label">PHP Extensions:</span>
                <span class="value"><span class="status-badge"><?php echo count(get_loaded_extensions()); ?> loaded</span></span>
            </div>
        </div>

        <details>
            <summary>View Loaded Extensions</summary>
            <div class="extensions-grid">
                <?php
                $extensions = get_loaded_extensions();
                sort($extensions);
                foreach ($extensions as $ext) {
                    echo '<div class="ext-item">' . htmlspecialchars($ext) . '</div>';
                }
                ?>
            </div>
        </details>

        <?php
        // Check for database credentials file
        $siteName = basename(dirname(__DIR__));
        $credentialsFile = '/var/www/credentials/' . $siteName . '.env';
        if (file_exists($credentialsFile)) {
            $credentials = parse_ini_file($credentialsFile);
            if ($credentials) {
                // Get server IP address
                $serverIp = $_SERVER['SERVER_ADDR'] ?? gethostbyname(gethostname());
                
                echo '<div class="credentials-box">';
                echo '<div class="credentials-title">🔐 Database Credentials</div>';
                echo '<div class="credentials-subtitle">Copy these to your Laravel <code>.env</code> file or find them in: <code style="color: #60A5FA;">credentials/' . htmlspecialchars($siteName) . '.env</code></div>';
                
                foreach (['DB_CONNECTION', 'DB_HOST', 'DB_PORT', 'DB_DATABASE', 'DB_USERNAME'] as $key) {
                    if (isset($credentials[$key])) {
                        echo '<div class="info-row">';
                        echo '<span class="label">' . htmlspecialchars($key) . ':</span>';
                        echo '<span class="value">' . htmlspecialchars($credentials[$key]) . '</span>';
                        echo '</div>';
                    }
                }
                
                // Show password location but not the actual password
                if (isset($credentials['DB_PASSWORD'])) {
                    echo '<div class="info-row">';
                    echo '<span class="label">DB_PASSWORD:</span>';
                    echo '<span class="value" style="color: #94A3B8;">••••••••••••••••••••</span>';
                    echo '</div>';
                    echo '<div style="padding: 10px; margin-top: 10px; background: rgba(139, 92, 246, 0.1); border-radius: 6px; border: 1px solid rgba(139, 92, 246, 0.2);">';
                    echo '<div style="color: #C4B5FD; font-size: 12px; line-height: 1.5;">🔒 <strong>Password Hidden:</strong> For security, the password is not displayed here. Find it in <code style="color: #A78BFA;">credentials/' . htmlspecialchars($siteName) . '.env</code></div>';
                    echo '</div>';
                }
                
                // Add server IP
                echo '<div class="info-row" style="margin-top: 15px; padding-top: 15px; border-top: 1px solid rgba(59, 130, 246, 0.2);">';
                echo '<span class="label">Server IP:</span>';
                echo '<span class="value">' . htmlspecialchars($serverIp) . '</span>';
                echo '</div>';
                
                // Generate TablePlus connection string
                if (isset($credentials['DB_USERNAME']) && isset($credentials['DB_PASSWORD']) && 
                    isset($credentials['DB_DATABASE']) && isset($credentials['DB_PORT'])) {
                    $tableplus = sprintf(
                        'mysql://%s@%s:%s/%s',
                        urlencode($credentials['DB_USERNAME']),
                        $serverIp,
                        $credentials['DB_PORT'],
                        urlencode($credentials['DB_DATABASE'])
                    );
                    
                    echo '<div class="info-row">';
                    echo '<span class="label">TablePlus URL:</span>';
                    echo '<span class="value" style="font-size: 11px; word-break: break-all;">' . htmlspecialchars($tableplus) . '</span>';
                    echo '</div>';
                    echo '<div style="padding: 15px; margin-top: 10px; background: rgba(59, 130, 246, 0.1); border-radius: 6px; border: 1px solid rgba(59, 130, 246, 0.2);">';
                    echo '<div style="color: #93C5FD; font-size: 13px; line-height: 1.6;">💡 <strong>Quick Connect:</strong> Copy the TablePlus URL above and paste it into TablePlus. You\'ll be prompted to enter the password from your credentials file.</div>';
                    echo '</div>';
                }
                
                echo '</div>';
            }
        }
        ?>

        <div class="note-box">
            <strong>📁 Next Steps:</strong>
            Clone or copy your Laravel project into:<br>
            <code>{SITE_NAME}</code><br><br>
            <?php if (file_exists(__DIR__ . '/../.env.credentials')): ?>
            Configure your Laravel <code>.env</code> with the database credentials above, then delete this <code>public/</code> folder.
            <?php else: ?>
            Once your Laravel app is in place, you can delete this <code>public/</code> folder.
            <?php endif; ?>
        </div>

        <div class="tip-box">
            <small>Laravel Multi-Site Development Environment</small>
        </div>
    </div>
</body>
</html>
