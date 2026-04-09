<?php
/**
 * Panel dashboard template
 *
 * @package {{PLUGIN_CLASS_PREFIX}}
 */

defined( 'ABSPATH' ) || exit;

if ( ! current_user_can( '{{TABLE_PREFIX}}view_reports' ) ) {
    wp_die( esc_html__( 'You do not have permission to access this page.', '{{TEXT_DOMAIN}}' ) );
}
?>
<!DOCTYPE html>
<html <?php language_attributes(); ?>>
<head>
    <meta charset="<?php bloginfo( 'charset' ); ?>">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo esc_html__( 'Dashboard', '{{TEXT_DOMAIN}}' ); ?> — <?php bloginfo( 'name' ); ?></title>
</head>
<body>
    <div class="panel-container">
        <h1><?php echo esc_html__( 'Dashboard', '{{TEXT_DOMAIN}}' ); ?></h1>
        <p><?php echo esc_html__( 'Welcome to the admin panel.', '{{TEXT_DOMAIN}}' ); ?></p>
    </div>
</body>
</html>
