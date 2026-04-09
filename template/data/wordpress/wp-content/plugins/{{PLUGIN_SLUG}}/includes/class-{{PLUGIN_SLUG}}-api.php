<?php
/**
 * REST API — Registers custom REST endpoints
 *
 * @package {{PLUGIN_CLASS_PREFIX}}
 */

defined( 'ABSPATH' ) || exit;

class {{PLUGIN_CLASS_PREFIX}}_API {

	const NAMESPACE = '{{PLUGIN_SLUG}}/v1';

	/**
	 * Initialize API routes
	 */
	public static function init() {
		add_action( 'rest_api_init', array( __CLASS__, 'register_routes' ) );
	}

	/**
	 * Register REST routes
	 */
	public static function register_routes() {
		register_rest_route(
			self::NAMESPACE,
			'/health',
			array(
				'methods'             => 'GET',
				'callback'            => array( __CLASS__, 'health_check' ),
				'permission_callback' => function () {
					return current_user_can( 'manage_options' );
				},
			)
		);
	}

	/**
	 * Health check endpoint
	 *
	 * @return WP_REST_Response
	 */
	public static function health_check() {
		return new WP_REST_Response(
			array(
				'status'  => 'ok',
				'version' => {{PLUGIN_CLASS_PREFIX}}_VERSION,
				'time'    => current_time( 'mysql' ),
			),
			200
		);
	}
}
