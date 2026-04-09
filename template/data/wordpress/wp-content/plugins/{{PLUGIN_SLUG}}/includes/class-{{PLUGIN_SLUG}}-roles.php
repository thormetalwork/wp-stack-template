<?php
/**
 * Roles — Custom roles and capabilities
 *
 * @package {{PLUGIN_CLASS_PREFIX}}
 */

defined( 'ABSPATH' ) || exit;

class {{PLUGIN_CLASS_PREFIX}}_Roles {

	/**
	 * Register custom roles on activation
	 */
	public static function register_roles() {
		add_role(
			'{{TABLE_PREFIX}}panel_admin',
			__( 'Panel Administrator', '{{TEXT_DOMAIN}}' ),
			array(
				'read'                   => true,
				'{{TABLE_PREFIX}}manage_panel' => true,
				'{{TABLE_PREFIX}}view_reports' => true,
				'{{TABLE_PREFIX}}manage_leads' => true,
			)
		);

		add_role(
			'{{TABLE_PREFIX}}panel_viewer',
			__( 'Panel Viewer', '{{TEXT_DOMAIN}}' ),
			array(
				'read'                   => true,
				'{{TABLE_PREFIX}}view_reports' => true,
			)
		);

		// Grant capabilities to admin
		$admin = get_role( 'administrator' );
		if ( $admin ) {
			$admin->add_cap( '{{TABLE_PREFIX}}manage_panel' );
			$admin->add_cap( '{{TABLE_PREFIX}}view_reports' );
			$admin->add_cap( '{{TABLE_PREFIX}}manage_leads' );
		}
	}

	/**
	 * Remove custom roles on deactivation
	 */
	public static function remove_roles() {
		remove_role( '{{TABLE_PREFIX}}panel_admin' );
		remove_role( '{{TABLE_PREFIX}}panel_viewer' );
	}
}
