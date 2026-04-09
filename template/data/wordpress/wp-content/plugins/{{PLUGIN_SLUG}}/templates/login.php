<?php
/**
 * Login template
 *
 * @package {{PLUGIN_CLASS_PREFIX}}
 */

defined( 'ABSPATH' ) || exit;
?>
<!DOCTYPE html>
<html <?php language_attributes(); ?>>
<head>
    <meta charset="<?php bloginfo( 'charset' ); ?>">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo esc_html__( 'Login', '{{TEXT_DOMAIN}}' ); ?> — <?php bloginfo( 'name' ); ?></title>
</head>
<body>
    <div class="login-container">
        <h1><?php echo esc_html__( 'Panel Login', '{{TEXT_DOMAIN}}' ); ?></h1>
        <?php wp_login_form(); ?>
    </div>
</body>
</html>
