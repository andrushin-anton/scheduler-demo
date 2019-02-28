// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require moment
//= require turbolinks
//= require_tree .
//= require bootstrap-datepicker
//= require s3_direct_upload

$(document).on('turbolinks:load', function() {
    process_attachments();

    $('.cell-phone').mask('000-000-0000');
    $('.home-phone').mask('000-000-0000');

    $(".select-all-checkboxes").change(function() {
        $("input:checkbox").prop('checked', $(this).prop("checked"));
    });

    $(".day-checkbox").change(function() {
        var day = $(this).val();
        $("." + day).prop('checked', $(this).prop("checked"));
    });

    $('.datepicker-seller').datepicker({ dateFormat: 'yy-mm-dd' });
    $('.datepicker-followup').datepicker({ dateFormat: 'yy-mm-dd' });
    $('.datepicker-delivery').datepicker({ dateFormat: 'yy-mm-dd' });
    $('.datepicker-delivery-dead-line').datepicker({ dateFormat: 'yy-mm-dd' });
    $('.datepicker-reschedule').datepicker({ dateFormat: 'yy-mm-dd' });
    $('.datepicker-seller').change(function() {
        var date = new Date($(this).val());
        var corrected_date = date.getFullYear() + '-' + (parseInt(date.getMonth()) + 1) + '-' + date.getDate();
        $("#corrected_date").val(corrected_date);
    });
    $('.datepicker-followup').change(function() {
        var date = new Date($(this).val());
        var corrected_date = date.getFullYear() + '-' + (parseInt(date.getMonth()) + 1) + '-' + date.getDate();
        $("#followup_corrected_date").val(corrected_date);
    });
    $('.datepicker-reschedule').change(function() {
        var date = new Date($(this).val());
        var corrected_date = date.getFullYear() + '-' + (parseInt(date.getMonth()) + 1) + '-' + date.getDate();
        $("#reschedule_corrected_date").val(corrected_date);
    });
    $('.datepicker-delivery').change(function() {
        var date = new Date($(this).val());
        var corrected_date = date.getFullYear() + '-' + (parseInt(date.getMonth()) + 1) + '-' + date.getDate();
        $("#delivery_corrected_date").val(corrected_date);
    });
    $('.datepicker-delivery-dead-line').change(function() {
        var date = new Date($(this).val());
        var corrected_date = date.getFullYear() + '-' + (parseInt(date.getMonth()) + 1) + '-' + date.getDate();
        $("#delivery_dead_line_corrected_date").val(corrected_date);
    });

    $('.datepicker').datepicker({ dateFormat: 'yy-mm-dd' });
    $('.datepicker').change(function() {
        var date = new Date($(this).val());
        var corrected_date = date.getFullYear() + '-' + (parseInt(date.getMonth()) + 1) + '-' + date.getDate();
        var appointment_id = $('#appointment_id').val();
        $("#corrected_date").val(corrected_date);

        find_booking_available(appointment_id, corrected_date).done(function(data) {
            $('#time-frame-select').html(data);
        });

        if ($('#appointment_status').val() == 'Sold') {
            find_installers_available(appointment_id, corrected_date).done(function(data) {
                $('#installers-select').html(data);
            });
        }
    });

    $('.grills-select').change(function() {
        if ($(this).val() == 'NO') {
            $('.grills-type-div').hide();
            $('.grills-type-select').hide();
        } else {
            $('.grills-type-div').show();
            $('.grills-type-select').show();
        }
    });

    $('.sold-form').change(function() {
        process_attachments();
    });

    $('#s3_uploader').S3Uploader({
        remove_completed_progress_bar: false,
        progress_bar_target: $('#uploads_container')
    });

    $('#s3_uploader').bind('s3_upload_complete', function(e, content) {
        var attachments_count = parseInt($('#sold-attachments-count').val());
        attachments_count = attachments_count + 1;
        $('#sold-attachments-count').val(attachments_count);
        process_attachments();
    });

    $('#s3_uploader').bind('s3_upload_failed', function(e, content) {
        return alert(content.filename + ' failed to upload. Error: ' + content.error_thrown);
    });
});


function find_booking_available(appointment_id, date) {
    return $.ajax({
        url: '/bookings/available/' + appointment_id + '/' + date,
        type: 'GET'
    });
}

function find_installers_available(appointment_id, date) {
    return $.ajax({
        url: '/installers/available/' + appointment_id + '/' + date,
        type: 'GET'
    });
}

function redirect(url) {
    window.location.href = url;
}

function select_seller_option(value) {
    if (value == 'none') {
        $('.seller-action-form').hide();
    } else if (value == 'followup') {
        $('.seller-action-form').hide();
        $('#followup-seller-action-form').show();
    } else if (value == 'sold') {
        $('.seller-action-form').hide();
        $('#sold-seller-action-form').show();
    } else if (value == 'canceled') {
        $('.seller-action-form').hide();
        $('#canceled-seller-action-form').show();
    } else if (value == 'reschedule') {
        $('.seller-action-form').hide();
        $('#reschedule-seller-action-form').show();
    }
}

function select_appointment_time_frame(value) {
    var schedule_time = $('#corrected_date').val();
    var schedule_date = schedule_time.split(' ')[0];
    var end_time = processEndTime(value);

    $('#corrected_date').val(schedule_date + ' ' + value);
    $('#end_time').val(schedule_date + ' ' + end_time);
}

function processEndTime(value) {
    var end_time = '09:59:59';
    if (value == '09:00:00') {
        end_time = '09:59:59';
    }
    if (value == '10:00:00') {
        end_time = '11:59:59';
    }
    if (value == '12:00:00') {
        end_time = '13:59:59';
    }
    if (value == '14:00:00') {
        end_time = '15:59:59';
    }
    if (value == '16:00:00') {
        end_time = '17:59:59';
    }
    if (value == '18:00:00') {
        end_time = '19:59:59';
    }
    if (value == '20:00:00') {
        end_time = '21:00:00';
    }
    return end_time;
}

function process_attachments() {
    var attachments_count = parseInt($('#sold-attachments-count').val());
    var minimum_files = 1;

    if (attachments_count >= minimum_files) {
        $('#submit-sold').attr('disabled', false);
    } else {
        $('#submit-sold').attr('disabled', true);
    }

    console.log('Minimum:' + minimum_files);

}