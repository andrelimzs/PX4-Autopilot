@###############################################
@#
@# EmPy template
@#
@###############################################
@# generates CDR serialization & deserialization methods
@#
@# Context:
@#  - spec (msggen.MsgSpec) Parsed specification of the .msg file
@###############################################
@{
import genmsg.msgs
from px_generate_uorb_topic_helper import * # this is in Tools/

topic = spec.short_name
uorb_struct = '%s_s'%spec.short_name

# get fields, struct size and paddings
field_sizes = []
offset = 0
for field in spec.parsed_fields():
	if not field.is_header:
		field_size = sizeof_field_type(field)

		# TODO: fix, support nested topics
###################
		if field_size == 0:
			field_sizes.append((field_size * array_size, padding))
			continue
###################
		assert field_size > 0

		padding = (field_size - (offset % field_size)) & (field_size - 1)

		type_name = field.type
		# detect embedded types
		sl_pos = type_name.find('/')
		if (sl_pos >= 0):
			type_name = type_name[sl_pos + 1:]

		# detect arrays
		a_pos = type_name.find('[')
		array_size = 1
		if (a_pos >= 0):
			# field is array
			array_size = int(type_name[a_pos+1:-1])
			type_name = type_name[:a_pos]

		field_sizes.append((field_size * array_size, padding))
		offset += array_size * field_size + padding

	# TODO: nested types

struct_size = offset

}@

// auto-generated file

#pragma once

#include <ucdr/microcdr.h>
#include <string.h>
#include <uORB/topics/@(topic).h>

int ucdr_topic_size_@(topic)()
{
	return @(struct_size);
}

bool ucdr_serialize_@(topic)(const @(uorb_struct)& topic, ucdrBuffer& buf)
{
	if (ucdr_buffer_remaining(&buf) < @(struct_size)) {
		return false;
	}
@{
size_idx = 0
for field in spec.parsed_fields():
	if not field.is_header:
		field_size, padding = field_sizes[size_idx]
		if padding > 0:
			print('\tbuf.iterator += {:}; // padding'.format(padding))
			print('\tbuf.offset += {:}; // padding'.format(padding))

		print('\tstatic_assert(sizeof(topic.{0}) == {1}, "size mismatch");'.format(field.name, field_size))
		print('\tmemcpy(buf.iterator, &topic.{0}, sizeof(topic.{0}));'.format(field.name))
		print('\tbuf.iterator += sizeof(topic.{:});'.format(field.name))
		print('\tbuf.offset += sizeof(topic.{:});'.format(field.name))

		# TODO: nested types

		size_idx += 1

}@
	return true;
}

bool ucdr_deserialize_@(topic)(ucdrBuffer& buf, @(uorb_struct)& topic)
{
	if (ucdr_buffer_remaining(&buf) < @(struct_size)) {
		return false;
	}
@{
size_idx = 0
for field in spec.parsed_fields():
	if not field.is_header:
		field_size, padding = field_sizes[size_idx]
		if padding > 0:
			print('\tbuf.iterator += {:}; // padding'.format(padding))
			print('\tbuf.offset += {:}; // padding'.format(padding))

		print('\tstatic_assert(sizeof(topic.{0}) == {1}, "size mismatch");'.format(field.name, field_size))
		print('\tmemcpy(&topic.{0}, buf.iterator, sizeof(topic.{0}));'.format(field.name))
		print('\tbuf.iterator += sizeof(topic.{:});'.format(field.name))
		print('\tbuf.offset += sizeof(topic.{:});'.format(field.name))

		# TODO: nested types

		size_idx += 1

}@
	return true;
}
