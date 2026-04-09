<?php
/**
 * Plugin Name:        {{PLUGIN_CLASS_PREFIX}} Panel
 * Plugin URI:         https://{{DEV_DOMAIN}}
 * Description:        Admin panel for {{PROJECT_NAME}}
 * Version:            0.1.0
 * Author:             {{PROJECT_NAME}} Dev
 * Text Domain:        {{TEXT_DOMAIN}}
 * Domain Path:        /languages
 * Requires PHP:       {{PHP_VERSION}}
 * Requires at least:  6.5
 * License:            Proprietary
 *
 * @package {{PLUGIN_CLASS_PREFIX}}
 */

defined( 'ABSPATH' ) || exit;

/* ═══════════════════════════════════════════
   Constants
   ═══════════════════════════════════════════ */

define( '{{PLUGIN_CLASS_PREFIX}}_VERSION', '0.1.0' );
define( '{{PLUGIN_CLASS_PREFIX}}_PATH', plugin_dir_path( __FILE__ ) );
define( '{{PLUGIN_CLASS_PREFIX}}_URL', plugin_dir_url( __FILE__ ) );

/* ═══════════════════════════════════════════
   Autoload includes
   ═══════════════════════════════════════════ */

$includes = array(
	'includes/class-{{PLUGIN_SLUG}}-router.php',
	'includes/class-{{PLUGIN_SLUG}}-api.php',
	'includes/class-{{PLUGIN_SLUG}}-roles.php',
);

foreach ( $includes as $file ) {
	$filepath = {{PLUGIN_CLASS_PREFIX}}_PATH . $file;
	if ( file_exists( $filepath ) ) {
		require_once $filepath;
	}
}

/* ═══════════════════════════════════════════
   Initialize plugin
   ═══════════════════════════════════════════ */

function {{TABLE_PREFIX}}panel_init() {
	// Initialize router
	if ( class_exists( '{{PLUGIN_CLASS_PREFIX}}_Router' ) ) {
		{{PLUGIN_CLASS_PREFIX}}_Router::init();
	}

	// Initialize API
	if ( class_exists( '{{PLUGIN_CLASS_PREFIX}}_API' ) ) {
		{{PLUGIN_CLASS_PREFIX}}_API::init();
	}
}
add_action( 'init', '{{TABLE_PREFIX}}panel_init' );

/* ═══════════════════════════════════════════
   Activation / Deactivation
   ═══════════════════════════════════════════ */

function {{TABLE_PREFIX}}panel_activate() {
	if ( class_exists( '{{PLUGIN_CLASS_PREFIX}}_Roles' ) ) {
		{{PLUGIN_CLASS_PREFIX}}_Roles::register_roles();
	}
	flush_rewrite_rules();
}
register_activation_hook( __FILE__, '{{TABLE_PREFIX}}panel_activate' );

function {{TABLE_PREFIX}}panel_deactivate() {
	flush_rewrite_rules();
}
register_deactivation_hook( __FILE__, '{{TABLE_PREFIX}}panel_deactivate' );
