<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Site Configured Successfully</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        @keyframes pulse {
            0%, 100% { box-shadow: 0 0 0 0 rgba(245, 82, 71, 0.7); }
            50% { box-shadow: 0 0 0 15px rgba(245, 82, 71, 0); }
        }
        
        .success-pulse {
            animation: pulse 2s ease-in-out infinite;
        }
    </style>
</head>
<body class="bg-[#0a0a0a] text-gray-100 min-h-screen flex items-center justify-center p-5">
    <div class="max-w-3xl w-full">
        <div class="bg-[#1a1a1a] border border-gray-800 rounded-xl shadow-2xl overflow-hidden">
            <!-- Header with gradient border -->
            <div class="h-1 bg-[#F55247]"></div>
            
            <div class="p-10">
                <!-- Success Icon -->
                <div class="flex justify-center mb-8">
                    <div class="w-20 h-20 bg-[#F55247] rounded-full flex items-center justify-center text-4xl success-pulse">
                        ✓
                    </div>
                </div>
                
                <h1 class="text-3xl font-bold text-center mb-2 text-white">
                    Site Configured Successfully!
                </h1>
                <p class="text-center text-gray-400 mb-8">Your development environment is ready and running</p>
                
                <!-- Info Box -->
                <div class="bg-[#0a0a0a] border border-gray-800 rounded-lg p-6 mb-6">
                    <div class="space-y-4">
                        <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-2 pb-3 border-b border-gray-800">
                            <span class="text-gray-400 text-sm">Site Name:</span>
                            <span class="font-mono text-gray-200 text-sm break-all">{SITE_NAME}</span>
                        </div>
                        <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-2 pb-3 border-b border-gray-800">
                            <span class="text-gray-400 text-sm">Domain:</span>
                            <span class="font-mono text-gray-200 text-sm break-all">{DOMAIN}</span>
                        </div>
                        <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-2 pb-3 border-b border-gray-800">
                            <span class="text-gray-400 text-sm">PHP Version:</span>
                            <span class="inline-block bg-gray-800 text-gray-200 px-4 py-1 rounded-full text-xs font-semibold">
                                PHP <?php echo phpversion(); ?>
                            </span>
                        </div>
                        <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-2 pb-3 border-b border-gray-800">
                            <span class="text-gray-400 text-sm">Server:</span>
                            <span class="font-mono text-gray-200 text-sm break-all"><?php echo $_SERVER['SERVER_SOFTWARE'] ?? 'nginx'; ?></span>
                        </div>
                        <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-2 pb-3 border-b border-gray-800">
                            <span class="text-gray-400 text-sm">Document Root:</span>
                            <span class="font-mono text-gray-200 text-xs break-all"><?php echo $_SERVER['DOCUMENT_ROOT']; ?></span>
                        </div>
                        <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-2">
                            <span class="text-gray-400 text-sm">PHP Extensions:</span>
                            <span class="inline-block bg-gray-800 text-gray-200 px-3 py-1 rounded-full text-xs font-semibold">
                                <?php echo count(get_loaded_extensions()); ?> loaded
                            </span>
                        </div>
                    </div>
                </div>

                <!-- Extensions Collapsible -->
                <details class="mb-6">
                    <summary class="cursor-pointer bg-[#0a0a0a] border border-gray-800 rounded-lg p-4 hover:border-gray-700 transition-colors text-gray-300 font-medium">
                        View Loaded Extensions
                    </summary>
                    <div class="bg-[#0a0a0a] border border-gray-800 border-t-0 rounded-b-lg p-4 grid grid-cols-3 md:grid-cols-5 gap-2">
                        <?php
                        $extensions = get_loaded_extensions();
                        sort($extensions);
                        foreach ($extensions as $ext) {
                            echo '<div class="bg-gray-800 text-gray-300 px-3 py-2 rounded text-xs text-center font-medium">' . htmlspecialchars($ext) . '</div>';
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
                        $serverIp = $_SERVER['SERVER_ADDR'] ?? gethostbyname(gethostname());
                        
                        echo '<div class="bg-[#0a0a0a] border border-gray-700 rounded-lg p-6 mb-6">';
                        echo '<div class="flex items-center gap-2 mb-2 text-gray-200 font-bold text-lg">Database Credentials</div>';
                        echo '<div class="text-gray-400 text-sm mb-4">Copy these to your Laravel <span class="font-mono bg-gray-800 px-2 py-1 rounded text-gray-300">.env</span> file or find them in: <span class="font-mono bg-gray-800 px-2 py-1 rounded text-gray-300">credentials/' . htmlspecialchars($siteName) . '.env</span></div>';
                        
                        echo '<div class="space-y-3">';
                        foreach (['DB_CONNECTION', 'DB_HOST', 'DB_PORT', 'DB_DATABASE', 'DB_USERNAME'] as $key) {
                            if (isset($credentials[$key])) {
                                echo '<div class="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-2 pb-2 border-b border-gray-800">';
                                echo '<span class="text-gray-400 text-sm">' . htmlspecialchars($key) . ':</span>';
                                echo '<span class="font-mono text-gray-200 text-sm break-all">' . htmlspecialchars($credentials[$key]) . '</span>';
                                echo '</div>';
                            }
                        }
                        
                        if (isset($credentials['DB_PASSWORD'])) {
                            echo '<div class="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-2 pb-2 border-b border-gray-800">';
                            echo '<span class="text-gray-400 text-sm">DB_PASSWORD:</span>';
                            echo '<span class="font-mono text-gray-500 text-sm">••••••••••••••••••••</span>';
                            echo '</div>';
                            echo '<div class="mt-3 bg-gray-900/50 border border-gray-700 rounded-lg p-3 text-gray-400 text-xs">';
                            echo '<strong>Password Hidden:</strong> For security, the password is not displayed. Find it in <span class="font-mono bg-gray-800 px-2 py-1 rounded">credentials/' . htmlspecialchars($siteName) . '.env</span>';
                            echo '</div>';
                        }
                        
                        echo '<div class="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-2 pb-2 border-b border-gray-800 mt-4 pt-4">';
                        echo '<span class="text-gray-400 text-sm">Server IP:</span>';
                        echo '<span class="font-mono text-gray-200 text-sm break-all">' . htmlspecialchars($serverIp) . '</span>';
                        echo '</div>';
                        
                        if (isset($credentials['DB_USERNAME']) && isset($credentials['DB_PASSWORD']) && 
                            isset($credentials['DB_DATABASE']) && isset($credentials['DB_PORT'])) {
                            $tableplus = sprintf(
                                'mysql://%s@%s:%s/%s',
                                urlencode($credentials['DB_USERNAME']),
                                $serverIp,
                                $credentials['DB_PORT'],
                                urlencode($credentials['DB_DATABASE'])
                            );
                            
                            echo '<div class="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-2 pb-2 border-b border-gray-800">';
                            echo '<span class="text-gray-400 text-sm">TablePlus URL:</span>';
                            echo '<span class="font-mono text-gray-200 text-xs break-all">' . htmlspecialchars($tableplus) . '</span>';
                            echo '</div>';
                            echo '<div class="mt-3 bg-gray-900/50 border border-gray-700 rounded-lg p-3 text-gray-400 text-xs">';
                            echo '<strong>Quick Connect:</strong> Copy the TablePlus URL above and paste it into TablePlus. You\'ll be prompted to enter the password from your credentials file.';
                            echo '</div>';
                        }
                        
                        echo '</div>';
                        echo '</div>';
                    }
                }
                ?>

                <!-- Next Steps -->
                <div class="bg-gray-900/30 border-l-4 border-[#F55247] rounded-lg p-5 mb-6">
                    <div class="text-[#F55247] font-bold mb-2">Next Steps:</div>
                    <div class="text-gray-300 text-sm space-y-2">
                        <p>Clone or copy your Laravel project into:</p>
                        <code class="block bg-gray-900 px-3 py-2 rounded font-mono text-gray-300">{SITE_NAME}</code>
                        <?php if (file_exists(__DIR__ . '/../.env.credentials')): ?>
                        <p class="mt-2">Configure your Laravel <code class="bg-gray-900 px-2 py-1 rounded font-mono text-gray-300">.env</code> with the database credentials above, then delete this <code class="bg-gray-900 px-2 py-1 rounded font-mono text-gray-300">public/</code> folder.</p>
                        <?php else: ?>
                        <p class="mt-2">Once your Laravel app is in place, you can delete this <code class="bg-gray-900 px-2 py-1 rounded font-mono text-gray-300">public/</code> folder.</p>
                        <?php endif; ?>
                    </div>
                </div>

                <!-- Footer -->
                <div class="text-center text-sm text-gray-400 mt-6">
                    Laravel Multi-Site Development Environment
                </div>
            </div>
        </div>
    </div>
</body>
</html>
