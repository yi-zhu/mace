#include <common.h>

__kernel void space_to_batch(__read_only image2d_t space_data,
                             __write_only image2d_t batch_data,
                             __private const int block_height,
                             __private const int block_width,
                             __private const int padding_height,
                             __private const int padding_width,
                             __private const int space_height,
                             __private const int space_width,
                             __private const int batch_height,
                             __private const int batch_width) {
  const int chan_idx = get_global_id(0);
  const int batch_w_idx = mul24(get_global_id(1), 4);
  const int batch_hb_idx = get_global_id(2);

  const int batch_b_idx = batch_hb_idx / batch_height;
  const int batch_h_idx = batch_hb_idx % batch_height;

  const int block_size = mul24(block_height, block_width);
  const int space_b_idx = batch_b_idx / block_size;
  const int remaining_batch_idx = batch_b_idx % block_size;
  const int space_h_idx = (remaining_batch_idx / block_width) +
      mul24(batch_h_idx, block_height) - padding_height;
  int space_w_idx = (remaining_batch_idx % block_width) +
      mul24(batch_w_idx, block_width) - padding_width;

  int2 space_coord = (int2)(mul24(chan_idx, space_width) + space_w_idx,
                            mul24(space_b_idx, space_height) + space_h_idx);
  DATA_TYPE4 value = READ_IMAGET(space_data, SAMPLER, space_coord);

  int2 batch_coord = (int2)(mul24(chan_idx, batch_width) + batch_w_idx, batch_hb_idx);
  WRITE_IMAGET(batch_data, batch_coord, value);

  space_coord.x += block_width;
  value = READ_IMAGET(space_data, SAMPLER, space_coord);

  batch_coord.x += 1;
  WRITE_IMAGET(batch_data, batch_coord, value);

  space_coord.x += block_width;
  value = READ_IMAGET(space_data, SAMPLER, space_coord);

  batch_coord.x += 1;
  WRITE_IMAGET(batch_data, batch_coord, value);

  space_coord.x += block_width;
  value = READ_IMAGET(space_data, SAMPLER, space_coord);

  batch_coord.x += 1;
  WRITE_IMAGET(batch_data, batch_coord, value);
}

__kernel void batch_to_space(__read_only image2d_t batch_data,
                             __write_only image2d_t space_data,
                             __private const int block_height,
                             __private const int block_width,
                             __private const int padding_height,
                             __private const int padding_width,
                             __private const int space_height,
                             __private const int space_width,
                             __private const int batch_height,
                             __private const int batch_width) {
  const int chan_idx = get_global_id(0);
  const int batch_w_idx = mul24(get_global_id(1), 4);
  const int batch_hb_idx = get_global_id(2);

  const int batch_b_idx = batch_hb_idx / batch_height;
  const int batch_h_idx = batch_hb_idx % batch_height;

  const int block_size = mul24(block_height, block_width);
  const int space_b_idx = batch_b_idx / block_size;
  const int remaining_batch_idx = batch_b_idx % block_size;
  const int space_h_idx = (remaining_batch_idx / block_width) +
      mul24(batch_h_idx, block_height) - padding_height;
  const int space_w_idx = (remaining_batch_idx % block_width) +
      mul24(batch_w_idx, block_width) - padding_width;

  int2 batch_coord = (int2)(mul24(chan_idx, batch_width) + batch_w_idx, batch_hb_idx);
  DATA_TYPE4 value = READ_IMAGET(batch_data, SAMPLER, batch_coord);

  int2 space_coord = (int2)(mul24(chan_idx, space_width) + space_w_idx,
                            mul24(space_b_idx, space_height) + space_h_idx);
  WRITE_IMAGET(space_data, space_coord, value);

  batch_coord.x += 1;
  value = READ_IMAGET(batch_data, SAMPLER, batch_coord);

  space_coord.x += block_width;
  WRITE_IMAGET(space_data, space_coord, value);

  batch_coord.x += 1;
  value = READ_IMAGET(batch_data, SAMPLER, batch_coord);

  space_coord.x += block_width;
  WRITE_IMAGET(space_data, space_coord, value);

  batch_coord.x += 1;
  value = READ_IMAGET(batch_data, SAMPLER, batch_coord);

  space_coord.x += block_width;
  WRITE_IMAGET(space_data, space_coord, value);
}
